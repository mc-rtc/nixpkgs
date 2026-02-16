{
  description = "mc-rtc Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixgl.url = "github:nix-community/nixGL";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

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

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { system, pkgs, ... }:
        let
          useLocal = builtins.getEnv "MC_RTC_USE_LOCAL" == "1";
          localWorkspace = "/home/arnaud/devel/mc-rtc-nix/workspace";
          overlays = [
            inputs.ros-overlay.overlays.default
            inputs.nixgl.overlay
            (import ./overlay.nix { inherit useLocal localWorkspace; })
          ];
          pkgs = import inputs.nixpkgs {
            inherit system overlays;
            rosVersion = "jazzy";
          };
          packages = {
            mc-rtc-superbuild = pkgs.mc-rtc-superbuild;
            mc-rtc-magnum = pkgs.mc-rtc-magnum;
          };
        in {
          packages = packages // {
            default = packages.mc-rtc-superbuild;
          };
          devShells.default = import ./shell.nix { inherit pkgs; };
          devShells.controller = import ./controller-shell.nix { inherit pkgs; };
          devShells.display = import ./display-shell.nix { inherit pkgs; };
        };
    };
}
