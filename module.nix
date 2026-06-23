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
  stdenv,
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

    with-python = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to build with Python (bindings) support.";
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
        { config.enable = lib.mkDefault false; }
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
            inherit stdenv;
            with-ros = cfg.with-ros;
            with-python = cfg.with-python;
          };
        }
        {
          name = "make-shell";
          value = make-shell.overlays.default;
        }
      ]
      ++ (lib.optional cfg.overlays.private {
        name = "mc-rtc-private";
        value = import ./overlay-private.nix {
          with-ros = cfg.with-ros;
          with-python = cfg.with-python;
        };
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
              };
            };

            default = {
              extends = [ "minimal" ];
              runtime = {
                observers = [ pkgs.mc-state-observation ];
                apps = [
                  pkgs.mc-rtc-magnum
                ]
                ++ lib.optionals cfg.with-ros [ pkgs.mc-rtc-ticker ];
              };
            };

            default-all-robots = {
              extends = [ "default" ];
              runtime = {
                robots = [
                  pkgs.mc-g1
                  pkgs.mc-h1
                  pkgs.mc-panda
                  pkgs.mc-panda-lirmm
                ]
                ++ lib.optionals cfg.with-ros [
                  pkgs.mc-ur5e
                ]
                ++ lib.optionals cfg.overlays.private [
                  pkgs.mc-hrp2
                  pkgs.mc-hrp4
                  pkgs.mc-hrp5-p
                  # FIXME: disable mc-rhps1 as it is too heavy
                  # pkgs.mc-rhps1
                ];
              };
            };

            full = {
              extends = [ "default-all-robots" ];
              runtime = {
                plugins = [
                  pkgs.mc-robot-model-update
                ]
                ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
                  pkgs.mc-force-shoe-plugin
                ];
                apps = lib.optionals (cfg.overlays.private && !pkgs.stdenv.hostPlatform.isDarwin) [
                  pkgs.mc-mujoco-full
                ];
              };
            };
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
                  name =
                    (lib.optionalString (shellBaseName != "") "${shellBaseName}-")
                    + "${preset}"
                    + lib.optionalString (mode == "devel") "-devel";
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

          filterConfgurations =
            defaultShells_: autoShells_:
            if defaultShells_ then
              configurations
            else
              lib.optionalAttrs autoShells_ superbuildCfg.configurations;
          releaseShellsByPreset = mkShellsByPreset "release" (
            filterConfgurations superbuildCfg.shells.defaultShells.release superbuildCfg.shells.autoShells.release
          );
          develShellsByPreset = mkShellsByPreset "devel" (
            filterConfgurations superbuildCfg.shells.defaultShells.devel superbuildCfg.shells.autoShells.devel
          );

          explicitShells = lib.mapAttrs (
            name: shellCfg:
            mkSuperbuildShell {
              mode = shellCfg.mode;
              shellPname = name;
              configuration = shellCfg.configuration;
            }
          ) superbuildCfg.shells.additionalShells;

          hasExplicitShells = superbuildCfg.shells.additionalShells != { };
          generatedShells =
            if hasExplicitShells then explicitShells else releaseShellsByPreset // develShellsByPreset;
        in
        {
          # TODO: auto-generate
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
              inherit (pkgs)
                mc-rtc-magnum
                mc-franka
                ;

              # Main robots
              inherit (pkgs)
                mc-g1
                mc-h1
                mc-ur5e
                mc-panda
                mc-panda-lirmm
                ;

              # Robot description
              inherit (pkgs)
                mc-int-obj-description
                jvrc-description
                ;

              # MuJoCo Robots
              inherit (pkgs)
                h1-mj-description
                jvrc1-mj-description
                g1-mj-description
                ur5e-mj-description
                env-mj-description
                ;

              inherit (pkgs) panda-prosthesis mc-force-shoe-plugin sphinx-cmake;
            })
            (lib.mkIf cfg.with-ros {
              inherit (pkgs)
                mc-rtc-ticker
                ;
            })
            # TODO: support these on darwin
            (lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
              inherit (pkgs)
                mc-udp
                ;
              inherit (pkgs)
                mc-mujoco
                mc-mujoco-full
                ;
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
            # auto-generated release and devel shells for mc-rtc-superbuild
            (lib.mkIf superbuildCfg.enable generatedShells)
          ];
        }
      );
    };
}
