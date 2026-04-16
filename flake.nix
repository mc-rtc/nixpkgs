{
  description = "mc-rtc Nix flake (extends gepetto's)";

  inputs = {
    gepetto.url = "github:gepetto/nix";
    flake-parts.follows = "gepetto/flake-parts";
    nixpkgs.follows = "gepetto/nixpkgs";
    systems.follows = "gepetto/systems";
    jrl-cmakemodulesv2 = {
      url = "github:ahoarau/jrl-cmakemodules?ref=jrl-next";
    };
    # Only keep project-specific inputs here
  };

  nixConfig = {
    extra-substituters = [
      "https://mc-rtc-nix.cachix.org"
      "https://gepetto.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    extra-trusted-public-keys = [
      "mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs="
      "gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      let
        enablePrivateOverlay = false;
        flakeModule = inputs.flake-parts.lib.importApply ./module.nix {
          inherit (inputs) gepetto jrl-cmakemodulesv2;
          inherit enablePrivateOverlay;
        };
        flakeModulePrivate = inputs.flake-parts.lib.importApply ./module.nix {
          inherit (inputs) gepetto jrl-cmakemodulesv2;
          enablePrivateOverlay = true;
        };
      in
      {
        systems = import inputs.systems;
        # systems =
        # [
        #   "x86_64-linux"
        # ];
        imports = [
          flakeModule
        ];
        flake = {
          inherit flakeModule;
          inherit flakeModulePrivate;
          lib.mkFlakoboros =
            localInputs: module:
            inputs.flake-parts.lib.mkFlake { inputs = localInputs; } (args: {
              systems = import inputs.systems;
              imports = [
                flakeModule
                { flakoboros = module args; }
              ];
            });
          templates = {
            default = {
              path = ./templates/default;
              description = "A template for use with mc-rtc/nixpkgs";
            };
            controller = {
              path = ./templates/controller;
              description = "A template with superbuild configuration for use with mc-rtc/nixpkgs";
            };
            ros = {
              path = ./templates/ros;
              description = "A template for use with mc-rtc/nixpkgs and ROS";
            };
          };
        };
        perSystem =
          {
            inputs', # per-system inputs
            pkgs,
            ...
          }:
          {
            packages =
              inputs'.gepetto.packages
              // {
                # Main dependencies
                spacevecalg = pkgs.spacevecalg;
                rbdyn = pkgs.rbdyn;
                sch-core = pkgs.sch-core;
                tasks = pkgs.tasks;
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
                # Includes private repositories
                mc-rtc-superbuild-full = pkgs.mc-rtc-superbuild-full;
                # Main controllers
                panda-prosthesis = pkgs.panda-prosthesis;
                polytopeController = pkgs.polytopeController;

                # Main plugins
                mc-force-shoe-plugin = pkgs.mc-force-shoe-plugin;

                # Main robots
                mc-g1 = pkgs.mc-g1;
                mc-h1 = pkgs.mc-h1;
                mc-ur5e = pkgs.mc-ur5e;
                mc-panda = pkgs.mc-panda;
                mc-panda-lirmm = pkgs.mc-panda-lirmm;
              }
              // (
                if enablePrivateOverlay then
                  {
                    # Private robots
                    mc-hrp2 = pkgs.mc-hrp2;
                    mc-hrp4 = pkgs.mc-hrp4;
                    mc-hrp5-p = pkgs.mc-hrp5-p;
                    # Fixme this repository is far too big!
                    mc-rhps1 = pkgs.mc-rhps1;

                    # Superbuild configurations needing at least one private package
                    mc-rtc-superbuild-private = pkgs.mc-rtc-superbuild-private;
                    mc-rtc-superbuild-hugo = pkgs.mc-rtc-superbuild-hugo;
                  }
                else
                  { }
              );
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
              // (
                if enablePrivateOverlay then
                  {
                    mc-rtc-superbuild-private = import ./shell.nix {
                      inherit pkgs;
                      with-ros = true;
                      mc-rtc-superbuild = pkgs.mc-rtc-superbuild-private;
                    };
                  }
                else
                  { }
              );
          };
      }
    );
}
