{
  description = "mc-rtc Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ros-overlay.url = "github:lopsided98/nix-ros-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, ros-overlay }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = [
            ros-overlay.overlays.default
            (import ./overlay.nix) 
          ];
          rosVersion = "jazzy";
        };
      in {
        packages = {
          mc-rtc = pkgs.mc-rtc;
        };
        overlays = {
          default = import ./overlay.nix;
        };
        devShells.default = import ./controller-shell.nix { pkgs = pkgs; };
      }
    );

  nixConfig = {
    extra-substituters = [
      # "https://mc-rtc.cachix.org"
      "https://mc-rtc-nix.cachix.org"
      "https://ros.cachix.org"
    ];
    extra-trusted-public-keys = [
      # "mc-rtc.cachix.org-1:/ZR5oOY0Kb3A0bMuQ8lm8znlWt9POORuTCxJMF+b5ss="
      "mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
    ];
  };
}
