{
  description = "mc-rtc Nix flake: public/private overlays for mc-rtc ecosystem that extends gepetto's";

  inputs = {
    gepetto.url = "github:gepetto/nix";
    flake-parts.follows = "gepetto/flake-parts";
    flakoboros.follows = "gepetto/flakoboros";
    nixpkgs.follows = "gepetto/nixpkgs";
    systems.follows = "gepetto/systems";
    jrl-cmakemodulesv2 = {
      url = "github:jrl-umi3218/jrl-cmakemodules";
      inputs.gepetto.follows = "gepetto";
    };
    make-shell.url = "github:nicknovitski/make-shell";

    # A tiny community repository that just yields a true/false value
    # This is used by CI to activate the private overlay while remaining in pure evaluation mode
    # Use as nix build . --override-input private-trigger github:boolean-option/true
    private-trigger.url = "github:boolean-option/false";
    ccache-trigger.url = "github:boolean-option/true";
    with-ros-trigger.url = "github:boolean-option/true";
    with-python-trigger.url = "github:boolean-option/true";
  };

  outputs =
    { self, ... }@inputs:
    let
      flakeModule = inputs.flake-parts.lib.importApply ./module.nix {
        inherit (inputs)
          gepetto
          flakoboros
          jrl-cmakemodulesv2
          make-shell
          ;
        mc-rtc-lib = self.lib;
      };
      inputTriggers = {
        buildPrivate = inputs.private-trigger.value or false;
        with-ros = inputs.with-ros-trigger.value or true;
        with-python = inputs.with-python-trigger.value or true;
        ccache = inputs.ccache-trigger.value or false;
      };

      mkFlakoboros =
        {
          localInputs,
          localFlakeModule ? flakeModule,
        }:
        mcRtcFlakeModule:
        inputs.flake-parts.lib.mkFlake { inputs = localInputs; } (args: {
          systems = import inputs.systems;
          imports = [
            localFlakeModule
            { flakoboros = mcRtcFlakeModule args; }
          ];
        });

      mkMcRtcModule =
        {
          localInputs,
          defaultAttrs ? { },
          localFlakeModule ? flakeModule, # mc-rtc-nix flakeModule
        }:
        mcRtcFlakeModule:
        inputs.flake-parts.lib.mkFlake { inputs = localInputs; } (args: {
          systems = import inputs.systems;
          imports = [
            localFlakeModule # inputs.mc-rtc-nix.flakeModule
            ((mcRtcFlakeModule args) // defaultAttrs)
          ];
        });

      mkMcRtcController =
        {
          localInputs,
          controllerName,
          mkControllerSuperbuild,
          localFlakeModule ? flakeModule, # mc-rtc-nix flakeModule
        }:
        mkMcRtcModule {
          inherit localInputs localFlakeModule;
          defaultAttrs = {
            mc-rtc-superbuild =
              { pkgs, ... }:
              {
                enable = true;
                configurations = {
                  "${controllerName}" = (mkControllerSuperbuild pkgs (builtins.getAttr controllerName pkgs) { });
                };
              };
          };
        };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = import inputs.systems;
        imports = [
          flakeModule
          {
            mc-rtc-nix = {
              packages = true;
              with-ros = inputTriggers.with-ros;
              with-python = inputTriggers.with-python;
              # gepetto.packages = true;
              # gepetto.devShells = true;
              overlays = {
                private = inputTriggers.buildPrivate;
                ccache = inputTriggers.ccache;
              };
            };
            mc-rtc-superbuild = {
              enable = true;
              shells.defaultShells.release = true;
            };
          }
        ];

        flake = {
          inherit flakeModule;

          lib =
            let
              mc-rtc-lib = import ./lib { inherit lib; };
            in
            mc-rtc-lib
            // {
              # lib.mkFlakoboros
              #   Usage: lib.mkFlakoboros localInputs module
              #   Description: Creates a flake using the default flakeModule
              #   Arguments:
              #     - localInputs: The flake inputs set.
              #     - flakoborosModule: The flake-parts module to use.
              #                         See https://gepetto.github.io/flakoboros/index.html
              mkFlakoboros =
                localInputs: flakoborosModule:
                builtins.trace "mkFlakoboros is deprecated, please use mkMcRtcModule instead" mkFlakoboros {
                  inherit localInputs;
                } flakoborosModule;

              # lib.mkMcRtcModule
              #   Usage: lib.mkFlakoboros localInputs module
              #   Description: Creates a flake using the default flakeModule (public, with-ros).
              #   Arguments:
              #     - localInputs: The flake inputs set.
              #     - flakoborosModule: The flake-parts module to use.
              #                         See https://gepetto.github.io/flakoboros/index.html
              mkMcRtcModule = localInputs: mcRtcModule: mkMcRtcModule { inherit localInputs; } mcRtcModule;

              # lib.mkMcRtcController
              #   Same as mkMcRtcModule but adds a default configuration for the controller (defined in ${controller}.passthru.mc-rtc)
              #   Usage: lib.mkMcRtcController localInputs "controller-name" module
              #   Description: Creates a flake using the default flakeModule and configures mc-rtc-superbuild with
              #      a default configuration for the controller (defined in ${controller}.passthru.mc-rtc)
              #   Arguments:
              #     - localInputs: The flake inputs set.
              #     - controllerName: Name of the controller
              #     - flakoborosModule: The flake-parts module to use.
              #                         See https://gepetto.github.io/flakoboros/index.html
              mkMcRtcController =
                localInputs: controllerName: flakoborosModule:
                mkMcRtcController {
                  inherit localInputs controllerName;
                  mkControllerSuperbuild = mc-rtc-lib.mkControllerSuperbuild;
                } flakoborosModule;
            };

          templates = {
            default = {
              path = ./templates/default;
              description = "A template for use with mc-rtc/nixpkgs";
            };
            controller = {
              path = ./templates/controller;
              description = "A template with superbuild configuration for use with mc-rtc/nixpkgs";
            };
            flakoboros = {
              path = ./templates/flakoboros;
              description = "A flakoboros template for simple projects";
            };
            flakoboros-new-package = {
              path = ./templates/flakoboros-new-package;
              description = "A flakoboros template for simple projects";
            };
            flakoboros-new-cpp-package = {
              path = ./templates/flakoboros-new-cpp-package;
              description = "A flakoboros template for C++ projects (cmake + catch2 + jrl-cmakemodules)";
            };
            ros = {
              path = ./templates/ros;
              description = "A template for use with mc-rtc/nixpkgs and ROS";
            };
          };
        };
      }
    );
}
