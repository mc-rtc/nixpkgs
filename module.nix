# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
{
  gepetto,
  flakoboros,
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
let
  cfg = config.mc-rtc-nix;
  flakoboros-cfg = config.flakoboros;
  rosDistro =
    let
      distro = flakoboros-cfg.rosShellDistro;
    in
    builtins.trace "rosDistro evaluated to: ${distro}" distro;

  qtVersion =
    let
      version = flakoboros.lib.ros2qt rosDistro;
    in
    builtins.trace "qtVersion evaluated to: ${version}" version;

  # Define overlays as pure functions to avoid accessing `pkgs` at the root config level
  mcRtcPkgsOverlay =
    final: prev:
    let
      qt = if (qtVersion == "5") then final.qt5 else final.qt6;
    in
    (import ./overlay.nix {
      inherit lib;
      stdenv = prev.stdenv;
      with-ros = cfg.with-ros;
      with-python = cfg.with-python;
      inherit qt;
    })
      final
      prev;

  mcRtcPrivateOverlay =
    final: prev:
    let
      qt = if (qtVersion == "5") then final.qt5 else final.qt6;
    in
    (import ./overlay-private.nix {
      with-ros = cfg.with-ros;
      with-python = cfg.with-python;
      inherit qt;
    })
      final
      prev;

  jrlCmakeModulesOverlay = _final: prev: {
    jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default;
  };

  mcRtcCcacheOverlay = import ./overlay-ccache.nix { };

  superbuildFlakeModule = ./modules/superbuild/superbuild.nix;
in
{
  options.mc-rtc-nix = {
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

    packages = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "adds mc-rtc-nix packages";
    };
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

  config = {
    flake.overlays = {
      mc-rtc-pkgs = mcRtcPkgsOverlay;
      make-shell = make-shell.overlays.default;
    }
    // lib.optionalAttrs cfg.overlays.private {
      mc-rtc-private = mcRtcPrivateOverlay;
    }
    // {
      jrl-cmakemodulesv2 = jrlCmakeModulesOverlay;
    }
    // lib.optionalAttrs cfg.overlays.ccache {
      mc-rtc-ccache = mcRtcCcacheOverlay;
    };

    flake.flakeModules.superbuild = superbuildFlakeModule;

    flakoboros = {
      # FIXME: Flakoboros pulls in qtwayland that does not exist on macos
      enableQt = false;
      rosShellDistro = "kilted";
      extraPackages = [ "ninja" ];
      overlays = [
        mcRtcPkgsOverlay
        make-shell.overlays.default
      ]
      ++ lib.optional cfg.overlays.private mcRtcPrivateOverlay
      ++ [ jrlCmakeModulesOverlay ]
      ++ lib.optional cfg.overlays.ccache mcRtcCcacheOverlay;

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
            runtime = { };
          };

          default = {
            extends = [ "minimal" ];
            runtime = {
              observers = [ pkgs.mc-state-observation ];
              apps = [
                pkgs.mc-rtc-magnum
              ]
              ++ lib.optionals (cfg.with-ros || superbuildCfg.withRos) [ pkgs.mc-rtc-ticker ];
            };
          };

          default-all-robots = {
            extends = [ "default" ];
            runtime = with pkgs; {
              robots = [
                mc-g1
                mc-h1
                mc-panda
                mc-panda-lirmm
                mc-robogami
              ]
              ++ lib.optionals (cfg.with-ros || superbuildCfg.withRos) [
                mc-ur5e
              ]
              ++ lib.optionals cfg.overlays.private [
                mc-hrp2
                mc-hrp4
                mc-hrp5-p
              ];
              controllers = [ robogami-controller ];
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
          mode: configs:
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
            ) (builtins.attrNames configs)
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
        packages = lib.mkMerge [
          (lib.mkIf cfg.gepetto.packages inputs'.gepetto.packages)
          (lib.mkIf cfg.packages (
            lib.mergeAttrsList [
              {
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
                  mc-robogami
                  ;

                # Robot description
                inherit (pkgs)
                  mc-int-obj-description
                  jvrc-description
                  g1-description
                  h1-description
                  ur5e-description
                  robogami-description
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
              }
              (lib.optionalAttrs (cfg.with-ros || superbuildCfg.withRos) {
                inherit (pkgs) mc-rtc-ticker;
              })
              (lib.optionalAttrs (!pkgs.stdenv.hostPlatform.isDarwin) {
                inherit (pkgs) mc-udp mc-mujoco mc-mujoco-full;
              })
              (lib.optionalAttrs cfg.overlays.private {
                inherit (pkgs)
                  mc-hrp2
                  mc-hrp4
                  mc-hrp5-p
                  mc-rhps1
                  tasks-lssol
                  politopix
                  mc-dynamic-polytopes
                  dcm-vrptask
                  polytopeController
                  ;
              })
            ]
          ))
        ];

        devShells = lib.mkMerge [
          (lib.mkIf cfg.gepetto.devShells inputs'.gepetto.devShells)
          (lib.mkIf superbuildCfg.enable generatedShells)
        ];
      }
    );
  };
}
