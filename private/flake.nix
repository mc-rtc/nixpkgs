{
  description = "mc-rtc private flake (with private overlay and packages)";

  inputs = {
    gepetto.url = "github:gepetto/nix";
    flake-parts.follows = "gepetto/flake-parts";
    nixpkgs.follows = "gepetto/nixpkgs";
    systems.follows = "gepetto/systems";
    jrl-cmakemodulesv2 = {
      url = "github:ahoarau/jrl-cmakemodules?ref=jrl-next";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://mc-rtc-nix.cachix.org"
      "https://attic.arntanguy.fr/mc-rtc-nix-private"
      "https://gepetto.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    extra-trusted-public-keys = [
      "mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs="
      "mc-rtc-nix-private:jXpQCG0bFJIJxAuQpHQEyRsF+PyUcvIyFmnBcR5kEuo="
      "gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      let
        flakeModulePrivate = inputs.flake-parts.lib.importApply ../module.nix {
          inherit (inputs) gepetto jrl-cmakemodulesv2;
          enablePrivateOverlay = true;
        };
      in
      {
        systems = import inputs.systems;
        imports = [
          flakeModulePrivate
        ];
        perSystem =
          { inputs', pkgs, ... }:
          import ../perSystem-shared.nix {
            inherit pkgs inputs';
            extraPackages = {
              # Private robots
              mc-hrp2 = pkgs.mc-hrp2;
              mc-hrp4 = pkgs.mc-hrp4;
              mc-hrp5-p = pkgs.mc-hrp5-p;
              mc-rhps1 = pkgs.mc-rhps1;
              # Superbuild configurations needing at least one private package
              mc-rtc-superbuild-private = pkgs.mc-rtc-superbuild-private;
            };
            extraDevShells = {
              mc-rtc-superbuild-private = import ../shell.nix {
                inherit pkgs;
                with-ros = true;
                mc-rtc-superbuild = pkgs.mc-rtc-superbuild-private;
              };
            };
          };
      }
    );
}
