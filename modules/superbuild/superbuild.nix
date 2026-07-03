{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.mc-rtc-superbuild;
  resolver = import ./resolver.nix { inherit lib; } cfg;

  pname = cfg.project.pname;
  relativeLocalPath = cfg.project.relativeLocalPath;

  isDevel = cfg.mode == "devel";

  activeRuntime =
    if isDevel then resolver.resolved.devel.runtime else resolver.resolved.release.runtime;
  develOverlay = resolver.resolved.devel.devel;

  mainRobot = resolver.resolved.mainRobot;
  enabled = resolver.resolved.enabled;
  timeStep = resolver.resolved.timeStep;

  localPath = "$PWD/${relativeLocalPath}";
  localInstallPath = "${localPath}/install";

  normalizeRelativeConfig =
    cfgPath: fallbackPkg:
    if cfgPath == null || cfgPath == "" then
      null
    else if lib.hasPrefix "/" cfgPath || fallbackPkg == null then
      cfgPath
    else
      "${fallbackPkg}/${cfgPath}";

  normalizeRelativeConfigList =
    paths: fallbackPkg: map (p: normalizeRelativeConfig p fallbackPkg) paths;

  activeMainController =
    if activeRuntime.controllers == [ ] then null else lib.head activeRuntime.controllers;

  activeConfigPath =
    if isDevel then
      normalizeRelativeConfig develOverlay.config localInstallPath
    else
      normalizeRelativeConfig activeRuntime.config activeMainController;

  extraConfigPaths =
    if isDevel then
      normalizeRelativeConfigList develOverlay.extraConfigFiles localInstallPath
    else
      normalizeRelativeConfigList activeRuntime.extraConfigFiles activeMainController;

  traceGroup =
    name: paths:
    if cfg.traceRuntimeDependencies then
      map (p: builtins.trace "${pname} ${name}: ${toString p}" p) paths
    else
      paths;

  allDevelPkgs =
    traceGroup "inputsFrom apps" develOverlay.apps
    ++ traceGroup "inputsFrom robots" develOverlay.robots
    ++ traceGroup "inputsFrom plugins" develOverlay.plugins
    ++ traceGroup "inputsFrom controllers" develOverlay.controllers
    ++ traceGroup "inputsFrom observers" develOverlay.observers;

  toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;

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
{
  options.mc-rtc-superbuild = import ./options.nix { inherit lib; };

  config = lib.mkIf cfg.enable {
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
      ++ traceGroup "apps" activeRuntime.apps
      ++ traceGroup "robots" activeRuntime.robots
      ++ traceGroup "plugins" activeRuntime.plugins
      ++ traceGroup "controllers" activeRuntime.controllers
      ++ traceGroup "observers" activeRuntime.observers
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
        devPrefix = lib.optional isDevel localInstallPath;
        shellControllers = devPrefix ++ activeRuntime.controllers;
        shellRobots = devPrefix ++ activeRuntime.robots;
        shellObservers = devPrefix ++ activeRuntime.observers;
        shellPlugins = devPrefix ++ activeRuntime.plugins;

        shellConfigs = [
          "${localPath}/mc_rtc.yaml"
        ]
        ++ lib.optional (activeConfigPath != null) activeConfigPath
        ++ extraConfigPaths;

        printRuntimeDeps =
          showPaths: listGroup:
          let
            formatItem =
              p:
              if showPaths then
                builtins.unsafeDiscardStringContext "${p}"
              else
                p.name or p.pname or "unknown-package";

            makeLoop =
              title': list:
              if list == [ ] then
                ""
              else
                ''
                  echo "${title'}:"
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
        export PROJECT_DIR="$(pwd)/${relativeLocalPath}"
        export INSTALL_DIR="$PROJECT_DIR/install"
        mkdir -p $INSTALL_DIR

        cat <<EOF_CONF > $PROJECT_DIR/mc_rtc.yaml
        ---
        ${lib.optionalString (mainRobot != null && mainRobot != "") "MainRobot: \"${mainRobot}\""}
        ${lib.optionalString (enabled != null && enabled != "") "Enabled: \"${enabled}\""}
        ${lib.optionalString (timeStep != null) "Timestep: ${toString timeStep}"}
        ControllerModulePaths: [${mkModulePaths "mc_controller" shellControllers}]
        RobotModulePaths: [${mkModulePaths "mc_robots" shellRobots}]
        ObserverModulePaths: [${mkModulePaths "mc_observers" shellObservers}]
        GlobalPluginPaths: [${mkModulePaths "mc_plugins" shellPlugins}]
        LoadUserConfiguration: false
        EOF_CONF

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
        echo "This shell was built from the '${resolver.selectedConfiguration}' mc-rtc-superbuild configuration."

        echo ""
        echo "It contains the following runtime dependencies installed by Nix:"
        ${printRuntimeDeps true activeRuntime}
        ${lib.optionalString isDevel ''
          echo ""
          echo 'This is a development shell, you should install the following dependencies from source in $INSTALL_DIR:'

          ${printRuntimeDeps false develOverlay}

          echo ""
          echo "To build this project, use:"
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
