{ lib, ... }:

let
  componentOptions = {
    apps = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    robots = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    controllers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    observers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    config = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    extraConfigFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional mc_rtc configuration fragments appended to MC_RTC_CONTROLLER_CONFIG.";
    };
  };

  runtimeOptions = componentOptions;
in
{
  enable = lib.mkEnableOption "enable";

  mode = lib.mkOption {
    type = lib.types.enum [
      "release"
      "devel"
    ];
    default = "release";
    description = "Internal shell mode used by generated release/devel shells.";
  };

  withRos = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  traceRuntimeDependencies = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  extraBuildInputs = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };

  configurations = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          extends = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };

          runtime = lib.mkOption {
            type = lib.types.submodule { options = runtimeOptions; };
            default = { };
          };

          devel = lib.mkOption {
            type = lib.types.submodule { options = componentOptions; };
            default = { };
          };
        };
      }
    );
    default = { };
    description = "Reusable named presets for mc-rtc-superbuild.";
  };

  shells = lib.mkOption {
    description = "Configuration for devShell generation.";
    default = { };
    type = lib.types.submodule {
      options = {
        defaultShells = lib.mkOption {
          description = "Enable auto-generation of default configuration shells.";
          default = { };
          type = lib.types.submodule {
            options = {
              release = lib.mkEnableOption "enable default release shells";
              devel = lib.mkEnableOption "enable default devel shells";
            };
          };
        };

        autoShells = lib.mkOption {
          description = "Auto-generate shells from your specified configurations.";
          default = { };
          type = lib.types.submodule {
            options = {
              release = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "auto-generate release shells";
              };
              devel = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "auto-generate devel shells";
              };
            };
          };
        };

        additionalShells = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                mode = lib.mkOption {
                  type = lib.types.enum [
                    "release"
                    "devel"
                  ];
                  default = "release";
                  description = "Shell mode: release or devel.";
                };

                configuration = lib.mkOption {
                  type = lib.types.str;
                  description = "Name of the configuration preset to use for this shell.";
                };
              };
            }
          );
          default = { };
          description = ''
            Explicit set of named devShells to generate.
            They are generated in addition to the auto-generated ones (activated by: defaultShells, autoShells).
          '';
        };
      };
    };
  };

  project = lib.mkOption {
    type = lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "mc-rtc-superbuild";
        };

        configuration = lib.mkOption {
          type = lib.types.str;
          default = "default";
        };

        relativeLocalPath = lib.mkOption {
          type = lib.types.str;
          default = ".superbuild";
        };

        runtime = lib.mkOption {
          type = lib.types.submodule { options = runtimeOptions; };
          default = { };
        };

        devel = lib.mkOption {
          type = lib.types.submodule { options = componentOptions; };
          default = { };
        };
      };
    };
    default = { };
  };
}
