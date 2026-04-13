{
  description = "mc-rtc Nix flake";

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
      # "https://ros.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    extra-trusted-public-keys = [
      "mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs="
      "gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY="
      # "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };

outputs = 
  inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } (
  { lib, ...}:
  let
    flakeModule = inputs.flake-parts.lib.importApply ./module.nix {
      inherit (inputs) gepetto jrl-cmakemodulesv2;
    };
  in
  {
      # systems = import inputs.systems;
      systems =
      [
        "x86_64-linux"
      ];
      imports =
      [
        flakeModule
      ];
      flake = {
        inherit flakeModule;
      };
      perSystem =
        {
          inputs', # per-system inputs
          pkgs,
          self',
          system,
          ...
        }:
        {
          devShells = inputs'.gepetto.devShells
          // 
          {
            mc-rtc-superbuild-rolkneematics = import ./shell.nix
            { 
              inherit pkgs;
              with-ros = true;
              mc-rtc-superbuild = pkgs.mc-rtc-superbuild-rolkneematics;
            };
          };
          packages = inputs'.gepetto.packages;
          # treefmt = inputs'.gepetto.treefmt;
        };
  });
}
