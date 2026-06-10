{
  description = "mc-rtc Nix flake: public/private overlays for mc-rtc ecosystem that extends gepetto's";

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
      mkModule =
        arg:
        let
          attrs = if builtins.isAttrs arg then arg else { };
        in
        inputs.flake-parts.lib.importApply ./module.nix (
          {
            inherit (inputs) gepetto jrl-cmakemodulesv2;
            lib = inputs.nixpkgs.lib;
          }
          // attrs
        );

      superbuildModule = inputs.flake-parts.lib.importApply ./modules/superbuild.nix ({
        nixpkgs = inputs.nixpkgs;
      });
      flakeModule = mkModule { importPerSystem = false; };
      flakeModuleCcache = mkModule {
        importPerSystem = false;
        enableCcacheOverlay = true;
      };
      flakeModulePrivate = mkModule {
        importPerSystem = false;
        enablePrivateOverlay = true;
      };
      flakeModulePrivateCcache = mkModule {
        importPerSystem = false;
        enablePrivateOverlay = true;
        enableCcacheOverlay = true;
      };

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
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({
      # Default flake-parts module (public, with-ros)
      systems = import inputs.systems;
      imports = [
        (mkModule { importPerSystem = true; })
        inputs.flake-parts.flakeModules.flakeModules
      ];

      flake = {
        flakeModules = {
          default = flakeModule;
          public = flakeModule;
          public-ccache = flakeModuleCcache;
          private = flakeModulePrivate;
          private-ccache = flakeModulePrivateCcache;
          superbuild = superbuildModule;
        };
        flakeModulePrivate = builtins.trace "WARNING: deprecated, use flakeModules.private or flakeModules.private-ccache instead" flakeModulePrivate;

        # lib.mkFlakoboros
        #   Usage: lib.mkFlakoboros localInputs module
        #   Description: Creates a flake using the default flakeModule (public, with-ros).
        #   Arguments:
        #     - localInputs: The flake inputs set.
        #     - flakoborosModule: The flake-parts module to use.
        #                         See https://gepetto.github.io/flakoboros/index.html
        lib.mkFlakoboros =
          localInputs: flakoborosModule: mkFlakoboros { inherit localInputs; } flakoborosModule;

        # lib.mkFlakoborosPrivate
        #   Usage: lib.mkFlakoborosPrivate localInputs module
        #   Description: Creates a flake using the private flakeModulePrivate (private, with-ros).
        #   Arguments:
        #     - localInputs: The flake inputs set.
        #     - flakoborosModule: The flake-parts module to use.
        #                         See https://gepetto.github.io/flakoboros/index.html
        lib.mkFlakoborosPrivate =
          localInputs: flakoborosModule:
          mkFlakoboros {
            inherit localInputs;
            localFlakeModule = flakeModulePrivate;
          } flakoborosModule;

        # lib.mkFlakoborosCustom
        #   Usage: lib.mkFlakoborosCustom localInputs localFlakeModule module
        #   Description: Creates a flake using a custom flake module (pass arguments to mc-rtc's nixpkgs flake module).
        #   Arguments:
        #     - localInputs: The flake inputs set.
        #     - localFlakeModule: The flake module to use.
        #     - flakoborosModule: The flake-parts module to use.
        #                         See https://gepetto.github.io/flakoboros/index.html
        # Example:
        # outputs = inputs:
        #   inputs.mc-rtc-nix.lib.mkFlakoborosCustom
        #     inputs
        #     (flakeModule { with-ros = false; })
        #     ({ lib, ... }: {
        #       # your flakoboros module here
        #       overrideAttrs.package = {
        #         src = lib.cleanSource ./.;
        #       }
        #     })
        lib.mkFlakoborosCustom =
          localInputs: localFlakeModule: flakoborosModule:
          mkFlakoboros { inherit localInputs localFlakeModule; } flakoborosModule;

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
    })
    // {
      variants = {
        default = inputs.flake-parts.lib.mkFlake { inherit inputs; } ({
          systems = import inputs.systems;
          imports = [ (mkModule { importPerSystem = true; }) ];
        });
        ccache = inputs.flake-parts.lib.mkFlake { inherit inputs; } ({
          systems = import inputs.systems;
          imports = [
            (mkModule {
              importPerSystem = true;
              enableCcacheOverlay = true;
            })
          ];
        });
        private = inputs.flake-parts.lib.mkFlake { inherit inputs; } ({
          systems = import inputs.systems;
          imports = [
            (mkModule {
              importPerSystem = true;
              enablePrivateOverlay = true;
            })
          ];
        });
        private-ccache = inputs.flake-parts.lib.mkFlake { inherit inputs; } ({
          systems = import inputs.systems;
          imports = [
            (mkModule {
              importPerSystem = true;
              enablePrivateOverlay = true;
              enableCcacheOverlay = true;
            })
          ];
        });
      };
    };

}
