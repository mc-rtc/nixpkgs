{ lib, config, ... }:

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
          type = lib.types.functionTo (lib.types.listOf lib.types.package);
          default = _pkgs: [ ];
        };

        apps = lib.mkOption {
          type = lib.types.functionTo (lib.types.listOf lib.types.package);
          default = _pkgs: [ ];
        };

        controllers = lib.mkOption {
          type = lib.types.functionTo (lib.types.listOf lib.types.package);
          default = _pkgs: [ ];
        };

        observers = lib.mkOption {
          type = lib.types.functionTo (lib.types.listOf lib.types.package);
          default = _pkgs: [ ];
        };

        plugins = lib.mkOption {
          type = lib.types.functionTo (lib.types.listOf lib.types.package);
          default = _pkgs: [ ];
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
                  type = lib.types.functionTo (lib.types.listOf lib.types.package);
                  default = _pkgs: [ ];
                };
                controllers = lib.mkOption {
                  type = lib.types.functionTo (lib.types.listOf lib.types.package);
                  default = _pkgs: [ ];
                };
                observers = lib.mkOption {
                  type = lib.types.functionTo (lib.types.listOf lib.types.package);
                  default = _pkgs: [ ];
                };
                plugins = lib.mkOption {
                  type = lib.types.functionTo (lib.types.listOf lib.types.package);
                  default = _pkgs: [ ];
                };
                apps = lib.mkOption {
                  type = lib.types.functionTo (lib.types.listOf lib.types.package);
                  default = _pkgs: [ ];
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

  config.perSystem =
    { pkgs, ... }:
    let
      makeShell =
        { isReleaseShell }:
        let
          isDevel = cfg.devel != null && !isReleaseShell;
          devel-cfg = if cfg.devel != null then cfg.devel else { };

          mergedControllers = (cfg.controllers pkgs) ++ (devel-cfg.controllers pkgs);

          activeCfg =
            if isReleaseShell then
              {
                pname = "${cfg.pname}-official";
                apps = (cfg.apps pkgs) ++ (devel-cfg.apps pkgs);
                robots = (cfg.robots pkgs) ++ (devel-cfg.robots pkgs);
                plugins = (cfg.plugins pkgs) ++ (devel-cfg.plugins pkgs);
                controllers = mergedControllers;
                observers = (cfg.observers pkgs) ++ (devel-cfg.observers pkgs);
                config =
                  if cfg.config != null && cfg.config != "" && (builtins.length mergedControllers > 0) then
                    "${lib.head mergedControllers}/${cfg.config}"
                  else
                    null;
              }
            else
              {
                pname = "${cfg.pname}-local";
                apps = cfg.apps pkgs;
                robots = cfg.robots pkgs;
                plugins = cfg.plugins pkgs;
                controllers = cfg.controllers pkgs;
                observers = cfg.observers pkgs;
                config =
                  if devel-cfg.config != null && devel-cfg.config != "" then
                    "${localInstallPath}/${devel-cfg.config}"
                  else
                    null;
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
            (devel-cfg.apps pkgs)
            ++ (devel-cfg.robots pkgs)
            ++ (devel-cfg.plugins pkgs)
            ++ (devel-cfg.controllers pkgs)
            ++ (devel-cfg.observers pkgs);
        in
        pkgs.mkShell {
          pname = builtins.trace "activeCfg is ${lib.toJSON activeCfg}" activeCfg.pname;
          cmakeFlags =
            lib.optionals isDevel (lib.flatten (map (pkg: pkg.cmakeFlags or [ ]) allDevelPkgs))
            ++ [ "-DCMAKE_INSTALL_PREFIX=${localInstallPath}" ];

          buildInputs =
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

          inputsFrom = lib.optionals isDevel (
            traceGroup "inputsFrom apps" (devel-cfg.apps pkgs)
            ++ traceGroup "inputsFrom robots" (devel-cfg.robots pkgs)
            ++ traceGroup "inputsFrom plugins" (devel-cfg.plugins pkgs)
            ++ traceGroup "inputsFrom controllers" (devel-cfg.controllers pkgs)
            ++ traceGroup "inputsFrom observers" (devel-cfg.observers pkgs)
          );

          shellHook =
            let
              shellControllers = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.controllers;
              shellRobots = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.robots;
              shellObservers = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.observers;
              shellPlugins = lib.optionals isDevel [ localInstallPath ] ++ activeCfg.plugins;
              shellConfigs = [ "${localPath}/mc_rtc.yaml" ] ++ [ activeCfg.config ];
            in
            ''
              mkdir -p ${localInstallPath}
              echo "Generating local mc_rtc.yaml in ${localPath}/mc_rtc.yaml..."
              cat <<EOF > ${localPath}/mc_rtc.yaml
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
                echo 'cmake -B build $cmakeFlags'
                echo 'cmake --build build --target install'
              "}
              export MC_RTC_DISABLE_CONVEX_GENERATION_PATCH="ON"
            '';
        };
    in
    lib.mkIf cfg.enable {
      devShells =
        let
          devel = makeShell { isReleaseShell = false; };
          release = makeShell { isReleaseShell = true; };
        in
        {
          ${devel.pname} = devel;
          ${release.pname} = release;
        };
    };
}
