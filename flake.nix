{
  description = "mc-rtc Nix flake";

  inputs = {
    gazebros2nix.url = "github:gepetto/gazebros2nix";
    nixpkgs.follows = "gazebros2nix/nixpkgs";
    nix-ros-overlay.follows = "gazebros2nix/nix-ros-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = inputs@{ flake-parts, nix-system-graphics, system-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        systemConfigs.default = system-manager.lib.makeSystemConfig {
          modules = [
            nix-system-graphics.systemModules.default
              ({
               config = {
               nixpkgs.hostPlatform = "x86_64-linux";
               system-manager.allowAnyDistro = true;
               system-graphics.enable = true;
               };
               })
          ];
        };
      };

      perSystem = { inputs', system, pkgs, ... }:
        let
          useLocal = builtins.getEnv "MC_RTC_USE_LOCAL" == "1";
          localWorkspace = "/home/arnaud/devel/mc-rtc-nix/workspace";
          # with-ros = (if builtins.getEnv "MC_RTC_WITH_ROS" != null then builtins.getEnv "MC_RTC_WITH_ROS" else "") == "1";
          with-ros = (let v = builtins.getEnv "MC_RTC_WITH_ROS"; in v == "" || v == "1");
          overlays = [
            inputs.nix-ros-overlay.overlays.default
            (import ./overlay.nix { inherit useLocal localWorkspace with-ros; })
          ];
          pkgs = import inputs.nixpkgs {
            inherit system overlays;
            rosVersion = "jazzy";
            config = {
              permittedInsecurePackages = [
                "openssl-1.1.1w" # for libfranka
              ];
            };
          };
          packages = {
            mc-rtc-superbuild = pkgs.mc-rtc-superbuild;
            # mc-rtc-magnum = pkgs.mc-rtc-magnum;
            system-manager = inputs'.system-manager.packages.default;
          };
        in {
          packages = packages // {
            default = packages.mc-rtc-superbuild;
          };
          devShells.default = import ./shell.nix { inherit pkgs; with-ros = true; };
          #devShells.controller = import ./controller-shell.nix { inherit pkgs; };
          #devShells.display = import ./display-shell.nix { inherit pkgs; };
        };
    };
}
