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
  options.mc-rtc = {
    enablePrivateOverlay = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    enableCcacheOverlay = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    importPackages = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    with-ros = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
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
      cfg = config.mc-rtc;

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
      ++ (lib.optional cfg.enablePrivateOverlay {
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
      ++ (lib.optional cfg.enableCcacheOverlay {
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
      overlaysListTraced = builtins.trace "mc-rtc-nix: adding additional overlays: ${builtins.toString (map (o: o.name) rawOverlays)}" overlaysList;

    in
    {
      flake.overlays = flakeOverlays;
      flake.flakeModules.superbuild = ./modules/superbuild/superbuild.nix;

      flakoboros = {
        extraPackages = [ "ninja" ];
        overlays = overlaysListTraced;
        nixpkgsConfig = {
          permittedInsecurePackages = [ "openssl-1.1.1w" ];
        };
      };

      perSystem = (
        { pkgs, ... }:
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
          packages =
            lib.mkIf cfg.importPackages
              # inputs'.gepetto.packages
              {
              }
            // {
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
            }
            // lib.optionalAttrs cfg.enablePrivateOverlay {
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
            };

          devShells = lib.optionalAttrs superbuildCfg.enable (
            let
              releaseName = "${superbuildCfg.pname}-release";
              develName = "${superbuildCfg.pname}-devel";
            in
            {
              ${develName} = pkgs.make-shell {
                imports = [ ./modules/superbuild/superbuild.nix ];
                mc-rtc-superbuild = superbuildCfg // {
                  pname = develName;
                  buildDevel = true;
                };
              };
              ${releaseName} = pkgs.make-shell {
                imports = [ ./modules/superbuild/superbuild.nix ];
                mc-rtc-superbuild = superbuildCfg // {
                  pname = releaseName;
                  buildDevel = false;
                };
              };
            }
          );
        }
      );
    };
}
