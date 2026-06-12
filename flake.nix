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
          };
        }
      ];

      flake = {
        inherit flakeModule;

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
    };
}
