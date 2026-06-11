{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.mc-rtc-superbuild;
in
{
  options.mc-rtc-superbuild = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "mc-rtc superbuild shells configuration";

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
      };
    };
    default = { };
    description = "Global configuration schema for generating mc-rtc superbuild development environments.";
  };

  config =
    let
      isDevel = cfg.devel != null;
      develRobots = if cfg.devel != null then cfg.devel.robots else [ ];
      develApps = if cfg.devel != null then cfg.devel.apps else [ ];
      develControllers = if cfg.devel != null then cfg.devel.controllers else [ ];
      develPlugins = if cfg.devel != null then cfg.devel.plugins else [ ];
      develObservers = if cfg.devel != null then cfg.devel.observers else [ ];
      develConfig = if cfg.devel != null then cfg.devel.config else null;

      mergedControllers = cfg.controllers ++ develControllers;

      activeCfg =
        if !isDevel then
          {
            pname = "${cfg.pname}-official";
            apps = cfg.apps ++ develApps;
            robots = cfg.robots ++ develRobots;
            plugins = cfg.plugins ++ develPlugins;
            controllers = mergedControllers;
            observers = cfg.observers ++ develObservers;
            config =
              if cfg.config != null && cfg.config != "" && (builtins.length mergedControllers > 0) then
                "${lib.head mergedControllers}/${cfg.config}"
              else
                null;
          }
        else
          {
            pname = "${cfg.pname}-local";
            apps = cfg.apps;
            robots = cfg.robots;
            plugins = cfg.plugins;
            controllers = cfg.controllers;
            observers = cfg.observers;
            config =
              if develConfig != null && develConfig != "" then "${localInstallPath}/${develConfig}" else null;
          };

      localPath = "$PWD/${cfg.relativeLocalPath}";
      localInstallPath = "${localPath}/install";

      traceGroup =
        name: paths:
        if cfg.traceRuntimeDependencies then
          map (p: builtins.trace "${activeCfg.pname} ${name}: ${toString p}" p) paths
        else
          paths;

      toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;
      title = "  ${activeCfg.pname} interactive shell  ";
      line = builtins.concatStringsSep "" (builtins.genList (_: "=") (builtins.stringLength title));

      allDevelPkgs =
        traceGroup "inputsFrom apps" develApps
        ++ traceGroup "inputsFrom robots" develRobots
        ++ traceGroup "inputsFrom plugins" develPlugins
        ++ traceGroup "inputsFrom controllers" develControllers
        ++ traceGroup "inputsFrom observers" develObservers;
    in
    lib.mkIf config.mc-rtc-superbuild.enable {
      name = activeCfg.pname;

      additionalArguments = {
        cmakeFlags = lib.optionals isDevel (lib.flatten (map (pkg: pkg.cmakeFlags or [ ]) allDevelPkgs));
      };

      packages =
        with pkgs;
        [
          cmake
          ninja
          gdb
          mc-rtc
        ]
        ++ traceGroup "apps" activeCfg.apps
        ++ traceGroup "robots" activeCfg.robots
        ++ traceGroup "plugins" activeCfg.plugins
        ++ traceGroup "controllers" activeCfg.controllers
        ++ traceGroup "observers" activeCfg.observers
        ++ cfg.extraBuildInputs
        ++ lib.optionals cfg.withRos [
          colcon
          rosPackages.jazzy.rclcpp
          rosPackages.jazzy.geometry-msgs
          rosPackages.jazzy.sensor-msgs
          rosPackages.jazzy.tf2-ros
          rosPackages.jazzy.xacro
        ];

      inputsFrom = lib.optionals isDevel allDevelPkgs;

      shellHook =
        let
          shellControllers = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.controllers;
          shellRobots = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.robots;
          shellObservers = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.observers;
          shellPlugins = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.plugins;
          shellConfigs =
            if activeCfg.config != null then
              [ "${localPath}/mc_rtc.yaml" ] ++ [ activeCfg.config ]
            else
              [ "${localPath}/mc_rtc.yaml" ];
        in
        builtins.trace "shellConfigs is ${builtins.toJSON shellConfigs}" ''
          export PROJECT_DIR="$(pwd)/${cfg.relativeLocalPath}"
          export INSTALL_DIR="$PROJECT_DIR/install"
          mkdir -p $INSTALL_DIR
          echo "Generating local mc_rtc.yaml in $PROJECT_DIR/mc_rtc.yaml..."
          cat <<EOF > $PROJECT_DIR/mc_rtc.yaml
          ---
          ${lib.optionalString (cfg.mainRobot != null && cfg.mainRobot != "") "MainRobot: ${cfg.mainRobot}"}
          ${lib.optionalString (cfg.enabled != null) "Enabled: [${lib.concatStringsSep "," cfg.enabled}]"}
          ${lib.optionalString (cfg.timestep != null) "Timestep: ${toString cfg.timestep}"}
          ControllerModulePaths: [${
            toYamlList (
              (map (p: "${p}/lib64/mc_controller") shellControllers)
              ++ (map (p: "${p}/lib/mc_controller") shellControllers)
            )
          }]
          RobotModulePaths: [${
            toYamlList (
              (map (p: "${p}/lib64/mc_robots") shellRobots) ++ (map (p: "${p}/lib/mc_robots") shellRobots)
            )
          }]
          ObserverModulePaths: [${
            toYamlList (
              (map (p: "${p}/lib64/mc_observers") shellObservers)
              ++ (map (p: "${p}/lib/mc_observers") shellObservers)
            )
          }]
          GlobalPluginPaths: [${
            toYamlList (
              (map (p: "${p}/lib64/mc_plugins") shellPlugins) ++ (map (p: "${p}/lib/mc_plugins") shellPlugins)
            )
          }]
          LoadUserConfiguration: false
          EOF

          export MC_RTC_PATH=${pkgs.mc-rtc}
          export MC_RTC_JEKYLL_PLUGINS=${pkgs.mc-rtc}/share/doc/mc-rtc/jekyll/plugins
          export MC_RTC_LIB=${pkgs.mc-rtc}/lib
          export MC_RTC_BIN=${pkgs.mc-rtc}/bin
          export MC_RTC_PKGCONFIG=${pkgs.mc-rtc}/lib/pkgconfig
          export MC_RTC_CONTROLLER_CONFIG=${lib.concatStringsSep ":" shellConfigs}

          export PATH=$MC_RTC_BIN:$PATH
          export LD_LIBRARY_PATH=${lib.optionalString isDevel "${localInstallPath}/lib:${localInstallPath}/lib64:"}$MC_RTC_LIB:$LD_LIBRARY_PATH
          export PKG_CONFIG_PATH=$MC_RTC_PKGCONFIG:$PKG_CONFIG_PATH

          export TMP=/tmp TMPDIR=/tmp TEMP=/tmp TEMPDIR=/tmp
          export NIX_CFLAGS_COMPILE=""
          export ROS_DOMAIN_ID=100

          echo "${line}"
          echo "${title}"
          echo "${line}"
          echo ""

          ${lib.optionalString isDevel "
                echo 'This is a development shell, build your local targets with:'
                echo 'cmake -B build $cmakeFlags -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR'
                echo 'cmake --build build --target install'
              "}
          export MC_RTC_DISABLE_CONVEX_GENERATION_PATCH="ON"
        '';
    };
}
