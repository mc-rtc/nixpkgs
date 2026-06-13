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

  defaults = lib.mkOption {
    type = lib.types.submodule {
      options = {
        package = lib.mkOption {
          type = lib.types.str;
          default = "default";
          description = "Default preset name for package-oriented use-cases.";
        };

        develShell = lib.mkOption {
          type = lib.types.str;
          default = "default";
          description = "Preset used to generate the default devel shell.";
        };

        releaseShell = lib.mkOption {
          type = lib.types.str;
          default = "full";
          description = "Preset used to generate the default release shell.";
        };
      };
    };
    default = { };
  };

  project = lib.mkOption {
    type = lib.types.submodule {
      options = {
        pname = lib.mkOption {
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
