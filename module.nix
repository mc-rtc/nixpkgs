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
            spacevecalg = pkgs.spacevecalg;
            rbdyn = pkgs.rbdyn;
            sch-core = pkgs.sch-core;
            tasks = pkgs.tasks;
            tasks-qld = pkgs.tasks-qld;
            tvm = pkgs.tvm;
            eigen-quadprog = pkgs.eigen-quadprog;
            eigen-qld = pkgs.eigen-qld;
            state-observation = pkgs.state-observation;
            mesh-sampling = pkgs.mesh-sampling;
            eigen-fmt = pkgs.eigen-fmt;

            # mc-rtc
            mc-rtc-data = pkgs.mc-rtc-data;
            mc-rtc = pkgs.mc-rtc;

            # Main GUIs and applications
            mc-rtc-magnum = pkgs.mc-rtc-magnum;
            mc-mujoco = pkgs.mc-mujoco;
            mc-rtc-ticker = pkgs.mc-rtc-ticker;
            # Control interfaces
            mc-franka = pkgs.mc-franka;

            # Main superbuild configurations
            mc-rtc-superbuild = pkgs.mc-rtc-superbuild;
            mc-rtc-superbuild-full = pkgs.mc-rtc-superbuild-full;
            # Main controllers
            panda-prosthesis = pkgs.panda-prosthesis;

            # Main plugins
            mc-force-shoe-plugin = pkgs.mc-force-shoe-plugin;

            # Main robots
            mc-g1 = pkgs.mc-g1;
            mc-h1 = pkgs.mc-h1;
            mc-ur5e = pkgs.mc-ur5e;
            mc-panda = pkgs.mc-panda;
            mc-panda-lirmm = pkgs.mc-panda-lirmm;
          }
          // lib.optionalAttrs enablePrivateOverlay {
            # Private robots
            mc-hrp2 = pkgs.mc-hrp2;
            mc-hrp4 = pkgs.mc-hrp4;
            mc-hrp5-p = pkgs.mc-hrp5-p;
            mc-rhps1 = pkgs.mc-rhps1;
            tasks-lssol = pkgs.tasks-lssol;
            politopix = pkgs.politopix;
            mc-dynamic-polytopes = pkgs.mc-dynamic-polytopes;
            dcm-vrptask = pkgs.dcm-vrptask;
            polytopeController = pkgs.polytopeController;
            # Superbuild configurations needing at least one private package
            mc-rtc-superbuild-private = pkgs.mc-rtc-superbuild-private;
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
