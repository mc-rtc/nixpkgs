{
  description = "mc-rtc Nix flake: public/private overlays for mc-rtc ecosystem that extends gepetto's";

  inputs = {
    gepetto.url = "github:gepetto/nix";
    flake-parts.follows = "gepetto/flake-parts";
    flakoboros.follows = "gepetto/flakoboros";
    nixpkgs.follows = "gepetto/nixpkgs";
    systems.follows = "gepetto/systems";
    jrl-cmakemodulesv2 = {
      url = "github:ahoarau/jrl-cmakemodules?ref=jrl-next";
    };
    make-shell.url = "github:nicknovitski/make-shell";

    # A tiny community repository that just yields a true/false value
    # This is used by CI to activate the private overlay while remaining in pure evaluation mode
    # Use as nix build . --override-input private-trigger github:boolean-option/true
    private-trigger.url = "github:boolean-option/false";
    ccache-trigger.url = "github:boolean-option/false";
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
    let
      flakeModule = inputs.flake-parts.lib.importApply ./module.nix {
        inherit (inputs) gepetto jrl-cmakemodulesv2 make-shell;
      };
      buildPrivate = inputs.private-trigger.value or false;

      mkFlakoboros =
        {
          localInputs,
          localFlakeModule ? flakeModule,
        }:
        flakoborosModule:
        inputs.flake-parts.lib.mkFlake { inputs = localInputs; } (args: {
          systems = import inputs.systems;
          imports = [
            localFlakeModule
            { flakoboros = flakoborosModule args; }
          ];
        });
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        flakeModule
        {
          mc-rtc-nix = {
            packages = true;
            # gepetto.packages = true;
            # gepetto.devShells = true;
            overlays = {
              private = buildPrivate;
            };
          };
          mc-rtc-superbuild = {
            enable = true;
            shells.defaultShells.release = true;
          };
        }
      ];

      flake = {
        inherit flakeModule;

        # lib.mkFlakoboros
        #   Usage: lib.mkFlakoboros localInputs module
        #   Description: Creates a flake using the default flakeModule (public, with-ros).
        #   Arguments:
        #     - localInputs: The flake inputs set.
        #     - flakoborosModule: The flake-parts module to use.
        #                         See https://gepetto.github.io/flakoboros/index.html
        lib.mkFlakoboros =
          localInputs: flakoborosModule: mkFlakoboros { inherit localInputs; } flakoborosModule;

        templates = {
          default = {
            path = ./templates/default;
            description = "A template for use with mc-rtc/nixpkgs";
          };
          controller = {
            path = ./templates/controller;
            description = "A template with superbuild configuration for use with mc-rtc/nixpkgs";
          };
          flakoboros = {
            path = ./templates/flakoboros;
            description = "A flakoboros template for simple projects";
          };
          ros = {
            path = ./templates/ros;
            description = "A template for use with mc-rtc/nixpkgs and ROS";
          };
        };
      };
    };
}
