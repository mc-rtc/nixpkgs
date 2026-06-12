{
  lib,
  pkgs,
  config,
  ...
}:

let
  # cfg = builtins.trace "config.mc-rtc-superbuild ${builtins.toJSON config.mc-rtc-superbuild}" config.mc-rtc-superbuild;
  cfg = config.mc-rtc-superbuild;
in
{
  options.mc-rtc-superbuild = import ./options.nix { inherit lib; };

  config =
    let
      isDevel = cfg.buildDevel;
      pname = cfg.pname;

      # Extract development dependencies safely
      devel =
        if cfg.devel != null then
          cfg.devel
        else
          {
            robots = [ ];
            apps = [ ];
            controllers = [ ];
            plugins = [ ];
            observers = [ ];
            config = null;
          };

      mergedControllers = cfg.controllers ++ devel.controllers;

      # Dynamically compute configuration based on mode
      activeCfg =
        if !isDevel then
          {
            apps = cfg.apps ++ devel.apps;
            robots = cfg.robots ++ devel.robots;
            plugins = cfg.plugins ++ devel.plugins;
            observers = cfg.observers ++ devel.observers;
            controllers = mergedControllers;
            config =
              if cfg.config != null && cfg.config != "" && mergedControllers != [ ] then
                "${lib.head mergedControllers}/${cfg.config}"
              else
                null;
          }
        else
          {
            inherit (cfg)
              apps
              robots
              plugins
              controllers
              observers
              ;
            config =
              if devel.config != null && devel.config != "" then "${localInstallPath}/${devel.config}" else null;
          };

      localPath = "$PWD/${cfg.relativeLocalPath}";
      localInstallPath = "${localPath}/install";

      # Wrap trace logic concisely
      traceGroup =
        name: paths:
        if cfg.traceRuntimeDependencies then
          map (p: builtins.trace "${pname} ${name}: ${toString p}" p) paths
        else
          paths;

      allDevelPkgs =
        traceGroup "inputsFrom apps" devel.apps
        ++ traceGroup "inputsFrom robots" devel.robots
        ++ traceGroup "inputsFrom plugins" devel.plugins
        ++ traceGroup "inputsFrom controllers" devel.controllers
        ++ traceGroup "inputsFrom observers" devel.observers;

      toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;

      # Helper to expand standard and 64bit library structures
      mkModulePaths =
        suffix: paths:
        toYamlList (
          lib.concatMap (p: [
            "${p}/lib64/${suffix}"
            "${p}/lib/${suffix}"
          ]) paths
        );

      title = "  ${pname} interactive shell" + lib.optionalString isDevel " (devel)" + "  ";
      line = lib.concatStrings (builtins.genList (_: "=") (builtins.stringLength title));

    in
    lib.mkIf config.mc-rtc-superbuild.enable {
      name = pname;

      additionalArguments = {
        cmakeFlags =
          lib.optionals isDevel (lib.flatten (map (pkg: pkg.cmakeFlags or [ ]) allDevelPkgs))
          ++ [ "-G Ninja" ];
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
        ++ lib.optionals cfg.withRos (
          with rosPackages.jazzy;
          [
            colcon
            rclcpp
            geometry-msgs
            sensor-msgs
            tf2-ros
            xacro
          ]
        );

      inputsFrom = lib.optionals isDevel allDevelPkgs;

      shellHook =
        let
          # Apply dev paths conditionally
          devPrefix = lib.optional isDevel localInstallPath;
          shellControllers = devPrefix ++ activeCfg.controllers;
          shellRobots = devPrefix ++ activeCfg.robots;
          shellObservers = devPrefix ++ activeCfg.observers;
          shellPlugins = devPrefix ++ activeCfg.plugins;

          shellConfigs = [
            "${localPath}/mc_rtc.yaml"
          ]
          ++ lib.optional (activeCfg.config != null) activeCfg.config;

          printRuntimeDeps =
            showPaths: listGroup:
            let
              # Format items dynamically based on the boolean argument
              formatItem =
                p:
                if showPaths then
                  builtins.unsafeDiscardStringContext "${p}"
                else
                  p.name or p.pname or "unknown-package";

              makeLoop =
                title: list:
                if list == [ ] then
                  ""
                else
                  ''
                    echo "${title}:"
                    for item in ${lib.concatStringsSep " " (map formatItem list)}; do
                      echo "      $item"
                    done
                  '';
            in
            ''
              ${makeLoop "  - Robot modules" listGroup.robots}
              ${makeLoop "  - Plugins" listGroup.plugins}
              ${makeLoop "  - Observers" listGroup.observers}
              ${makeLoop "  - Controllers" listGroup.controllers}
              ${makeLoop "  - Apps" listGroup.apps}
            '';
        in
        ''
          export PROJECT_DIR="$(pwd)/${cfg.relativeLocalPath}"
          export INSTALL_DIR="$PROJECT_DIR/install"
          mkdir -p $INSTALL_DIR

          # echo "Generating local mc_rtc.yaml in $PROJECT_DIR/mc_rtc.yaml..."
          cat <<EOF > $PROJECT_DIR/mc_rtc.yaml
          ---
          ${lib.optionalString (cfg.mainRobot != null && cfg.mainRobot != "") "MainRobot: ${cfg.mainRobot}"}
          ${lib.optionalString (cfg.enabled != null) "Enabled: [${lib.concatStringsSep "," cfg.enabled}]"}
          ${lib.optionalString (cfg.timestep != null) "Timestep: ${toString cfg.timestep}"}
          ControllerModulePaths: [${mkModulePaths "mc_controller" shellControllers}]
          RobotModulePaths: [${mkModulePaths "mc_robots" shellRobots}]
          ObserverModulePaths: [${mkModulePaths "mc_observers" shellObservers}]
          GlobalPluginPaths: [${mkModulePaths "mc_plugins" shellPlugins}]
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

          echo -e "\n${line}\n${title}\n${line}"
          echo "This shell was built from an mc-rtc-superbuild configuration."

          echo ""
          echo "It contains the following runtime dependencies installed by Nix:"
          ${printRuntimeDeps true activeCfg}
          ${lib.optionalString isDevel ''
            echo ""
            echo 'This is a development shell, you should install the following dependencies from source in $INSTALL_DIR:'

            ${printRuntimeDeps false devel}

            echo ""
            echo "This is a development shell, build your local targets with:"
            echo ""
            echo '  cmake -B build $cmakeFlags -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR'
            echo "  cmake --build build --target install"
            echo ""
          ''}

          echo ""
          echo "The following convenience environment variables are set:"
          env | grep '^MC_RTC_'
          echo ""

          echo -e "mc_rtc will use the following configuration files $MC_RTC_CONTROLLER_CONFIG\n"
          export MC_RTC_DISABLE_CONVEX_GENERATION_PATCH="ON"
          echo -e "Warning:\n- MC_RTC_DISABLE_CONVEX_GENERATION_PATCH is set to ON, this will disable convex hull generation in mc_rtc\n"
          echo "--------"

        '';
    };
}
