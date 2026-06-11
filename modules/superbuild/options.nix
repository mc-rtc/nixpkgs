{ lib, ... }:
{
  enable = lib.mkEnableOption "enable";

  pname = lib.mkOption {
    type = lib.types.str;
    default = "mc-rtc-superbuild";
  };

  mainRobot = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
  };

  enabled = lib.mkOption {
    type = lib.types.nullOr (lib.types.listOf lib.types.str);
    default = null;
  };

  timestep = lib.mkOption {
    type = lib.types.nullOr lib.types.float;
    default = null;
  };

  relativeLocalPath = lib.mkOption {
    type = lib.types.str;
    default = ".superbuild";
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

  config = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
  };

  # Functional lazy-type listings to prevent infinite system recursion loops
  robots = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };

  apps = lib.mkOption {
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

  buildDevel = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "When true, packages in devel attribute sets are only added as inputsFrom but not built";
  };

  devel = lib.mkOption {
    default = null;
    type = lib.types.nullOr (
      lib.types.submodule {
        options = {
          config = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
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
          apps = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
        };
      }
    );
  };
}
