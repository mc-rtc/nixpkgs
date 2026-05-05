{
  description = "mc-rtc Nix flake (extends gepetto's)";

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
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      let
        # flakeModule = inputs.flake-parts.lib.importApply ./module.nix {
        #   inherit (inputs) gepetto jrl-cmakemodulesv2;
        # };
        # flakeModule = {enablePrivateOverlay ? false} :
        #   inputs.flake-parts.lib.importApply ./module.nix {
        #     inherit (inputs) gepetto jrl-cmakemodulesv2 enablePrivateOverlay;
        #   };

        # exports a flakeModule to be imported in other flakes
        # arg: can either be:
        #   - nothing: default arguments (public flake, with ros)
        #   - or an attribute set with:
        #       enablePrivateOverlay: whether to enable the private overlay (default: false)
        #       with-ros: whether to build the packages in the overlay with ROS support (default: true)
        #                 e.g that is robot description packages, mc-rtc, etc
        flakeModule =
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
        flakeModuleCcache = flakeModule { enableCcacheOverlay = true; };
        # Convenience module that enables the private overlay
        flakeModulePrivate = flakeModule { enablePrivateOverlay = true; };
        flakeModulePrivateCcache = flakeModule {
          enablePrivateOverlay = true;
          enableCcacheOverlay = true;
        };

        # mkFlakoboros
        #   Usage: mkFlakoboros { localInputs, localFlakeModule ? flakeModule } flakoborosModule
        #   - localInputs:        Flake inputs set.
        #   - localFlakeModule:   (Optional) Flake module to use (defaults to flakeModule).
        #   - flakoborosModule:   Flake-parts module (function of args).
        #                         See: https://gepetto.github.io/flakoboros/index.html
        #
        #   Example:
        #     outputs = inputs:
        #       mkFlakoboros { localInputs = inputs; } ({ lib, ... }: {
        #         config = { };
        #       })
        #
        #     # With custom flake module:
        #     outputs = inputs:
        #       mkFlakoboros {
        #         localInputs = inputs;
        #         localFlakeModule = flakeModule { with-ros = false; };
        #       } ({ lib, ... }: {
        #         config = { };
        #       })
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
      {
        systems = import inputs.systems;
        imports = [
          (flakeModule { })
        ];
        flake = {
          inherit flakeModule;

          lib = {
            inherit flakeModule;
            inherit flakeModulePrivate;
            inherit flakeModuleCcache;
            inherit flakeModulePrivateCcache;
          };

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
        perSystem =
          { inputs', pkgs, ... }:
          import ./perSystem-shared.nix {
            inherit pkgs inputs';
          };
      }
    );
}
