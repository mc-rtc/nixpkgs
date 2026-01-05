{
  description = "mc-rtc Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { nixpkgs, ... } @ inputs:
    inputs.flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        # USE MC_RTC_USE_LOCAL=1 env variable to use local workspace for mc-rtc-magnum
        # pass useLocal to packages that require it
        useLocal = builtins.getEnv "MC_RTC_USE_LOCAL" == "1";
        localWorkspace = "/home/arnaud/devel/mc-rtc-nix/workspace";

        pkgs = import nixpkgs {
          system = system;
          overlays = [
            inputs.ros-overlay.overlays.default
            inputs.nixgl.overlay
            (import ./overlay.nix { inherit useLocal localWorkspace; })
          ];
          rosVersion = "jazzy";
        };
        packages = {
          mc-rtc = pkgs.mc-rtc;
          mc-rtc-magnum = pkgs.mc-rtc-magnum;
        };
      in {
        packages = packages // {
          default = packages.mc-rtc;
        };
        # overlays = {
        #   default = import ./overlay.nix;
        # };
        devShells.default = import ./shell.nix { pkgs = pkgs; };
        devShells.controller = import ./controller-shell.nix { pkgs = pkgs; };
        devShells.display = import ./display-shell.nix { pkgs = pkgs; };
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
