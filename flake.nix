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

    nvim-nix = {
      url = "github:arntanguy/nvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jrl-cmakemodulesv2 = {
      url = "github:ahoarau/jrl-cmakemodules?ref=jrl-next";
    };
    jrl-cmakemodulesv2-test = {
      url = "git+file:///home/arnaud/devel/mc-rtc-nix/workspace/jrl-cmakemodules";
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
          # disable useLocal by default
          useLocal = builtins.getEnv "MC_RTC_USE_LOCAL" == "1";
          localWorkspace = "/home/arnaud/devel/mc-rtc-nix/workspace";
          # enable ros by default
          with-ros = (let v = builtins.getEnv "MC_RTC_WITH_ROS"; in v == "" || v == "1");
          overlays = [
            inputs.nix-ros-overlay.overlays.default
            (import ./overlay.nix { inherit useLocal localWorkspace with-ros; })
            (final: prev: {
              jrl-cmakemodulesv2 = inputs.jrl-cmakemodulesv2.packages.${prev.system}.default;
              jrl-cmakemodulesv2-test = inputs.jrl-cmakemodulesv2-test.packages.${prev.system}.default;
            })
            (import ./overlay-ccache.nix {})
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
            mc-rtc-superbuild-rolkneematics = pkgs.mc-rtc-superbuild-rolkneematics;
            mc-rtc-superbuild-hugo = pkgs.mc-rtc-superbuild-hugo;
            mc-rtc-magnum-standalone = pkgs.mc-rtc-magnum-standalone;
            mc-mujoco = pkgs.mc-mujoco;
            # mc-rtc-magnum = pkgs.mc-rtc-magnum;
            system-manager = inputs'.system-manager.packages.default;
          };
          devShells = {
            mc-rtc = pkgs.mkShell {
              inputsFrom = [ pkgs.mc-rtc ];
              buildInputs = [ pkgs.ninja ];
            };
            mc-rtc-superbuild = import ./shell.nix
            { 
              inherit pkgs;
              with-ros = true;
              mc-rtc-superbuild = packages.mc-rtc-superbuild;
              extraBuildInputs = [ inputs.nvim-nix.packages.${system}.nixCats ];
            };
            mc-rtc-superbuild-rolkneematics = import ./shell.nix
            { 
              inherit pkgs;
              with-ros = true;
              mc-rtc-superbuild = packages.mc-rtc-superbuild-rolkneematics;
              extraBuildInputs = [ inputs.nvim-nix.packages.${system}.nixCats ];
            };
            mc-rtc-superbuild-hugo = import ./shell.nix
            { 
              inherit pkgs;
              with-ros = true;
              mc-rtc-superbuild = packages.mc-rtc-superbuild-hugo;
              extraBuildInputs = [ inputs.nvim-nix.packages.${system}.nixCats ];
            };
            mc-rtc-superbuild-standalone-magnum = import ./shell.nix
            { 
              inherit pkgs;
              with-ros = true;
              mc-rtc-superbuild = pkgs.mc-rtc-superbuild-standalone-magnum;
              extraBuildInputs = [ inputs.nvim-nix.packages.${system}.nixCats ];
            };
            # Creates a custom devShell with all dependencies required to build mc_mujoco as defined in its derivation,
            # but without actually building the derivation
            # This can be used to test building the mc_mujoco app manually with all dependencies available (and a working find_pacakge)
            mc-mujoco = pkgs.mkShell {
              inputsFrom = [ pkgs.mc-mujoco ];
              buildInputs = [ pkgs.ninja ];
            };
            mc-rtc-imgui = pkgs.mkShell {
              inputsFrom = [ pkgs.mc-rtc-imgui ];
              buildInputs = [ pkgs.ninja ];
            };
            mc-rtc-magnum = pkgs.mkShell {
              inputsFrom = [ pkgs.mc-rtc-magnum ];
              buildInputs = [ pkgs.ninja ];
            };
            mc-rtc-magnum-standalone = pkgs.mkShell {
              inputsFrom = [ pkgs.mc-rtc-magnum-standalone ];
              buildInputs = [ pkgs.ninja ];
            };
          };
        in {
          packages = packages // {
            default = packages.mc-rtc-superbuild;
          };
          devShells = devShells // {
            default = devShells.mc-rtc-superbuild;
          };
        };
    };
}
