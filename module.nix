# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
{
  gepetto,
  jrl-cmakemodulesv2,
  make-shell,
  ...
}: # localFlake

# Regular module arguments; self, inputs, etc all reference the final user flake,
# where this module was imported.
{
  lib,
  config,
  ...
}:
{
  options.mc-rtc-nix = {
    # Root level option
    with-ros = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to build with ROS support.";
    };

    overlays = {
      private = lib.mkEnableOption "enables the private repository overlay";
      ccache = lib.mkEnableOption "enables the ccache overlay";
    };

    gepetto = {
      packages = lib.mkEnableOption "adds gepetto packages";
      devShells = lib.mkEnableOption "adds gepetto devShells";
    };

    packages = lib.mkEnableOption "adds mc-rtc-nix packages";
  };

  options.mc-rtc-superbuild = lib.mkOption {
    type = lib.types.deferredModuleWith {
      staticModules = [
        { config.enable = lib.mkDefault true; }
      ];
    };
    default = { };
    description = "mc-rtc superbuild configuration. Accepts a module attrset or a function of { pkgs, ... } returning a module attrset.";
  };

  imports = [
    gepetto.flakeModule
    make-shell.flakeModules.default
  ];

  config =
    let
      cfg = config.mc-rtc-nix;

      rawOverlays = [
        {
          name = "mc-rtc-pkgs";
          value = import ./overlay.nix {
            inherit lib;
            with-ros = cfg.with-ros;
          };
        }
        {
          name = "make-shell";
          value = make-shell.overlays.default;
        }
      ]
      ++ (lib.optional cfg.overlays.private {
        name = "mc-rtc-private";
        value = import ./overlay-private.nix { with-ros = cfg.with-ros; };
      })
      ++ [
        {
          name = "jrl-cmakemodulesv2";
          value = (
            _final: prev: { jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default; }
          );
        }
      ]
      ++ (lib.optional cfg.overlays.ccache {
        name = "mc-rtc-ccache";
        value = import ./overlay-ccache.nix { };
      });

      flakeOverlays = builtins.listToAttrs (
        map (o: {
          inherit (o) name;
          value = o.value;
        }) rawOverlays
      );

      overlaysList = map (o: o.value) rawOverlays;
      overlaysListTraced = builtins.trace "mc-rtc-nix: adding additional overlays: ${toString (map (o: o.name) rawOverlays)}" overlaysList;

      superbuildFlakeModule = ./modules/superbuild/superbuild.nix;

    in
    {
      flake.overlays = flakeOverlays;
      flake.flakeModules.superbuild = superbuildFlakeModule;

      flakoboros = {
        extraPackages = [ "ninja" ];
        overlays = overlaysListTraced;
        nixpkgsConfig = {
          permittedInsecurePackages = [ "openssl-1.1.1w" ];
        };
      };

      perSystem = (
        { pkgs, inputs', ... }:
        let
          superbuildCfg =
            (lib.evalModules {
              modules = [
                { options = import ./modules/superbuild/options.nix { inherit lib; }; }
                config.mc-rtc-superbuild
              ];
              specialArgs = { inherit pkgs; };
            }).config;

          builtInConfigurations = {
            minimal = {
              runtime = {
                observers = [ pkgs.mc-state-observation ];
              };
            };

            default = {
              extends = [ "minimal" ];
              runtime = {
                apps = [
                  pkgs.mc-rtc-magnum
                  pkgs.mc-mujoco
                ]
                ++ lib.optionals cfg.with-ros [ pkgs.mc-rtc-ticker ];
              };
            };

            all-public-robots = {
              extends = [ "default" ];
              runtime = {
                robots = [
                  pkgs.mc-g1
                  pkgs.mc-h1
                  pkgs.mc-ur5e
                ];
              };
            };

            full = {
              extends = [ "all-public-robots" ];
              runtime = {
                plugins = [
                  pkgs.mc-force-shoe-plugin
                  pkgs.mc-robot-model-update
                ];
                robots = lib.optionals cfg.overlays.private [
                  pkgs.mc-hrp2
                  pkgs.mc-hrp4
                  pkgs.mc-hrp5-p
                ];
                apps = lib.optionals cfg.overlays.private [ pkgs.mc-mujoco-full ];
              };
            };
          }
          // lib.optionalAttrs cfg.with-ros {
          };

          configurations = builtInConfigurations // superbuildCfg.configurations;

          mkSuperbuildShell =
            {
              mode,
              shellPname,
              configuration,
            }:
            pkgs.make-shell {
              imports = [ superbuildFlakeModule ];
              mc-rtc-superbuild = superbuildCfg // {
                inherit mode;
                withRos = cfg.with-ros;
                configurations = configurations;
                project = superbuildCfg.project // {
                  pname = shellPname;
                  inherit configuration;
                };
              };
            };

          shellBaseName = superbuildCfg.project.pname;

          mkShellsByPreset =
            mode: configurations:
            builtins.listToAttrs (
              map (
                preset:
                let
                  name = "${shellBaseName}-${preset}" + lib.optionalString (mode == "devel") "-devel";
                in
                {
                  inherit name;
                  value = mkSuperbuildShell {
                    mode = mode;
                    shellPname = name;
                    configuration = preset;
                  };
                }
              ) (builtins.attrNames configurations)
            );
          releaseShellsByPreset = mkShellsByPreset "release" configurations;
          develShellsByPreset = mkShellsByPreset "devel" configurations;

          explicitShells = lib.mapAttrs (
            name: shellCfg:
            mkSuperbuildShell {
              mode = shellCfg.mode;
              shellPname = name;
              configuration = shellCfg.configuration;
            }
          ) superbuildCfg.shells;

          hasExplicitShells = superbuildCfg.shells != { };

          generatedShells =
            if hasExplicitShells then
              explicitShells
            else
              releaseShellsByPreset // develShellsByPreset;
        in
        {
          packages = lib.mkMerge [
            (lib.mkIf cfg.gepetto.packages inputs'.gepetto.packages)
            (lib.mkIf cfg.packages {
              # Main dependencies
              inherit (pkgs)
                eigen3-to-python
                spacevecalg
                rbdyn
                sch-core
                sch-core-python
                tasks
                tasks-qld
                tvm
                eigen-quadprog
                eigen-qld
                state-observation
                mesh-sampling
                eigen-fmt
                ;

              # mc-rtc
              inherit (pkgs) mc-rtc-data mc-rtc;

              # Main GUIs and applications
              inherit (pkgs) mc-rtc-magnum mc-rtc-ticker mc-franka;

              # Main robots
              inherit (pkgs)
                mc-g1
                mc-h1
                mc-ur5e
                mc-panda
                mc-panda-lirmm
                ;

              # MuJoCo Robots
              inherit (pkgs)
                h1-mj-description
                jvrc1-mj-description
                g1-mj-description
                ur5e-mj-description
                env-mj-description
                ;

              inherit (pkgs)
                mc-mujoco
                mc-mujoco-full
                ;
              inherit (pkgs) panda-prosthesis mc-force-shoe-plugin sphinx-cmake;
            })
            (lib.mkIf (cfg.packages && cfg.overlays.private) {
              inherit (pkgs)
                mc-hrp2
                mc-hrp4
                mc-hrp5-p
                mc-rhps1
                tasks-lssol
                ;
              inherit (pkgs)
                politopix
                mc-dynamic-polytopes
                dcm-vrptask
                polytopeController
                ;
            })
          ];

          devShells = lib.mkMerge [
            (lib.mkIf cfg.gepetto.devShells inputs'.gepetto.devShells)
            (lib.mkIf superbuildCfg.enable generatedShells)
          ];
        }
      );
    };
}
