{
  description = "mc-rtc Nix flake";

  inputs = {
    gepetto.url = "github:gepetto/nix";
    flake-parts.follows = "gepetto/flake-parts";
    systems.follows = "gepetto/systems";
    jrl-cmakemodulesv2 = {
      url = "github:ahoarau/jrl-cmakemodules?ref=jrl-next";
    };
    # Only keep project-specific inputs here
  };

  nixConfig = {
    extra-substituters = [
      "https://mc-rtc-nix.cachix.org"
      "https://ros.cachix.org"
    ];
    extra-trusted-public-keys = [
      "mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
    ];
  };

outputs = 
  inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } (
  { lib, ...}:
  let
    flakeModule = inputs.flake-parts.lib.importApply ./module.nix {
      inherit (inputs) gepetto;
    };
  in
  {
      systems = import inputs.systems;
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
            mc-rtc = pkgs.mkShell {
              inputsFrom = [ pkgs.mc-rtc ];
              buildInputs = [ pkgs.ninja ];
            };
          };
          packages = inputs'.gepetto.packages;
          # treefmt = inputs'.gepetto.treefmt;
        };
  });
}
