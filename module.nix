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
    # we expect either a options.mc-rtc-superbuild set, or a function of { pkgs, ...}: options.mc-rtc-superbuid
    type = lib.types.unspecified;
    default =
      { pkgs, ... }:
      {
        enable = true;
        apps = [
          pkgs.mc-rtc-magnum
          pkgs.mc-rtc-ticker
          pkgs.mc-mujoco
        ];
      };
    description = "Global configuration schema or a function returning the schema for generating mc-rtc superbuild development environments.";
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
          # 1. Safely parse either formatting layout
          rawCfg =
            if builtins.isFunction config.mc-rtc-superbuild then
              config.mc-rtc-superbuild { inherit pkgs lib; }
            else
              config.mc-rtc-superbuild;

          # 2. Merge defaults so fields like .enable and .pname are always available
          superbuildCfg = {
            enable = false;
            pname = "mc-rtc-superbuild";
          }
          // rawCfg;
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
            (
              let
                releaseName = "${superbuildCfg.pname}";
                develName = "${superbuildCfg.pname}-devel";
              in
              lib.mkIf superbuildCfg.enable {
                ${develName} = pkgs.make-shell {
                  imports = [ superbuildFlakeModule ];
                  mc-rtc-superbuild = superbuildCfg // {
                    pname = develName;
                    buildDevel = true;
                  };
                };
                ${releaseName} = pkgs.make-shell {
                  imports = [ superbuildFlakeModule ];
                  mc-rtc-superbuild = superbuildCfg // {
                    pname = releaseName;
                    buildDevel = false;
                  };
                };
              }
            )
          ];
        }
      );
    };
}
