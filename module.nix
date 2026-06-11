# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
{ gepetto, jrl-cmakemodulesv2, ... }: # localFlake

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
    importPerSystem = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    with-ros = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  imports = [
    gepetto.flakeModule
    ./modules/superbuild.nix
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

      flakoboros = {
        extraPackages = [ "ninja" ];
        overlays = overlaysListTraced;
        nixpkgsConfig = {
          permittedInsecurePackages = [ "openssl-1.1.1w" ];
        };
      };

      perSystem = lib.mkIf cfg.importPerSystem (
        { pkgs, ... }:
        {
          packages =
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
                mc-rtc-superbuild
                mc-rtc-superbuild-full
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
              inherit (pkgs) mc-rtc-superbuild-private;
            };

          devShells =
            # inputs'.gepetto.devShells
            {
            }
            // {
              mc-rtc-superbuild-minimal = import ./shell.nix {
                inherit pkgs;
                with-ros = true;
                mc-rtc-superbuild = pkgs.mc-rtc-superbuild-minimal;
              };
              mc-rtc-superbuild = import ./shell.nix {
                inherit pkgs;
                with-ros = true;
                mc-rtc-superbuild = pkgs.mc-rtc-superbuild;
              };
              mc-rtc-superbuild-all-public-robots = import ./shell.nix {
                inherit pkgs;
                with-ros = true;
                mc-rtc-superbuild = pkgs.mc-rtc-superbuild-all-public-robots;
              };
              mc-rtc-superbuild-full = import ./shell.nix {
                inherit pkgs;
                with-ros = true;
                mc-rtc-superbuild = pkgs.mc-rtc-superbuild-full;
              };
            }
            // lib.optionalAttrs cfg.enablePrivateOverlay {
              mc-rtc-superbuild-private = import ../shell.nix {
                inherit pkgs;
                with-ros = true;
                mc-rtc-superbuild = pkgs.mc-rtc-superbuild-private;
              };
            };
        }
      );
    };
}
