{
  lib,
  gepetto,
  jrl-cmakemodulesv2,
  enablePrivateOverlay ? false,
  enableCcacheOverlay ? false,
  importPerSystem ? false,
  with-ros ? true,
  ...
}:
{ ... }:
let
  # define overlays as a list set of name/overlay
  rawOverlays = [
    {
      name = "mc-rtc-pkgs";
      value = import ./overlay.nix { inherit with-ros; };
    }
  ]
  ++ (lib.optional enablePrivateOverlay {
    name = "mc-rtc-private";
    value = import ./overlay-private.nix { inherit with-ros; };
  })
  ++ [
    {
      name = "jrl-cmakemodulesv2";
      value = (
        _final: prev: { jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default; }
      );
    }
  ]
  ++ (lib.optional enableCcacheOverlay {
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
  imports = [ gepetto.flakeModule ];

  config = {
    flake.overlays = flakeOverlays;

    flakoboros = {
      extraPackages = [ "ninja" ];
      overlays = overlaysListTraced;
      nixpkgsConfig = {
        permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };
    };
  }
  // lib.optionalAttrs importPerSystem {
    perSystem =
      { inputs', pkgs, ... }:
      {
        packages =
          inputs'.gepetto.packages
          // {
            # Main dependencies
            inherit (pkgs)
              spacevecalg
              rbdyn
              sch-core
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
            inherit (pkgs)
              mc-rtc-data
              mc-rtc
              ;

            # Main GUIs and applications
            inherit (pkgs)
              mc-rtc-magnum
              mc-rtc-ticker
              # Control interfaces
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

            # MuJoCo Robots
            inherit (pkgs)
              h1-mj-description
              jvrc1-mj-description
              g1-mj-description
              ur5e-mj-description
              env-mj-description
              ;
            # MuJoCo
            inherit (pkgs) mc-mujoco mc-mujoco-full;

            # Main superbuild configurations
            inherit (pkgs) mc-rtc-superbuild mc-rtc-superbuild-full;

            # Main controllers
            inherit (pkgs) panda-prosthesis;

            # Main plugins
            inherit (pkgs) mc-force-shoe-plugin;

          }
          // lib.optionalAttrs enablePrivateOverlay {
            # Private robots
            inherit (pkgs)
              mc-hrp2
              mc-hrp4
              mc-hrp5-p
              mc-rhps1
              ;
            inherit (pkgs) tasks-lssol;
            # Hugo's demo
            inherit (pkgs)
              politopix
              mc-dynamic-polytopes
              dcm-vrptask
              polytopeController
              ;
            # Superbuild configurations needing at least one private package
            inherit (pkgs) mc-rtc-superbuild-private;
          };

        devShells =
          inputs'.gepetto.devShells
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
          // lib.optionalAttrs enablePrivateOverlay {
            mc-rtc-superbuild-private = import ../shell.nix {
              inherit pkgs;
              with-ros = true;
              mc-rtc-superbuild = pkgs.mc-rtc-superbuild-private;
            };
          };
      };
  };
}
