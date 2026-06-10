{
  pkgs,
  lib,
  superbuildArgs ? { },
  develSuperbuildArgs ? null,
  relativeLocalPath ? ".superbuild",
  extraBuildInputs ? [ ],
  with-ros ? false,
}:

let
  localPath = "$PWD/" + relativeLocalPath;
  localInstallPath = localPath + "/install";
  default-cfg = builtins.trace "set default-cfg" {
    pname = superbuildArgs.pname or "mc-rtc-superbuild";
    MainRobot = superbuildArgs.MainRobot or "JVRC1";
    Enabled = superbuildArgs.Enabled or "CoM";
    Timestep = superbuildArgs.Timestep or 0.005;
    configs = superbuildArgs.configs or [ ];
    robots = superbuildArgs.robots or [ ];
    controllers = superbuildArgs.controllers or [ ];
    observers = superbuildArgs.observers or [ ];
    plugins = superbuildArgs.plugins or [ ];
    apps = superbuildArgs.apps or [ ];
  };
  cfg = superbuildArgs // default-cfg;
  isDevel = builtins.isAttrs develSuperbuildArgs;
  devel-cfg = if builtins.isAttrs develSuperbuildArgs then develSuperbuildArgs else { };

  traceGroup =
    name: pkgs:
    if cfg.traceRuntimeDependencies or false then
      map (p: builtins.trace "${cfg.pname} ${name}: ${toString p}" p) pkgs
    else
      pkgs;

  # Helper to build YAML lists
  toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;

  title = "  ${cfg.pname} interactive shell  ";
  line = builtins.concatStringsSep "" (builtins.genList (_: "=") (builtins.stringLength title));
in
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      cmake
      ninja
      gdb
      mc-rtc
    ]
    ++ traceGroup "apps" (cfg.apps or [ ])
    ++ traceGroup "robots" (cfg.robots or [ ])
    ++ traceGroup "plugins" (cfg.plugins or [ ])
    ++ traceGroup "controllers" (cfg.controllers or [ ])
    ++ traceGroup "observers" (cfg.observers or [ ])
    ++ extraBuildInputs
    ++ (
      if with-ros then
        [
          colcon
          rosPackages.jazzy.rclcpp
          rosPackages.jazzy.geometry-msgs
          rosPackages.jazzy.sensor-msgs
          rosPackages.jazzy.tf2-ros
          rosPackages.jazzy.xacro
          # Add more ROS packages as needed
        ]
      else
        [ ]
    );

  inputsFrom =
    [ ]
    ++ traceGroup "inputsFrom apps" (devel-cfg.apps or [ ])
    ++ traceGroup "inputsFrom robots" (devel-cfg.robots or [ ])
    ++ traceGroup "inputsFrom plugins" (devel-cfg.plugins or [ ])
    ++ traceGroup "inputsFrom controllers" (devel-cfg.controllers or [ ])
    ++ traceGroup "inputsFrom observers" (devel-cfg.observers or [ ]);

  # Explicitly inherit cmake flags from the development targets
  cmakeFlags =
    let
      # Gather all development packages
      develPkgs =
        (devel-cfg.apps or [ ])
        ++ (devel-cfg.robots or [ ])
        ++ (devel-cfg.plugins or [ ])
        ++ (devel-cfg.controllers or [ ])
        ++ (devel-cfg.observers or [ ]);

      # Extract cmakeFlags from packages safely (falling back to empty lists if they don't exist)
      extractedFlags = map (pkg: pkg.cmakeFlags or [ ]) develPkgs;
    in
    # Flatten the nested lists into a single list for cmakeFlags
    lib.flatten extractedFlags;

  shellHook =
    let
      controllers = lib.optionals isDevel [ localInstallPath ] ++ cfg.controllers;
      robots = lib.optionals isDevel [ localInstallPath ] ++ cfg.robots;
      observers = lib.optionals isDevel [ localInstallPath ] ++ cfg.observers;
      plugins = lib.optionals isDevel [ localInstallPath ] ++ cfg.plugins;
      configs = [
        "${localPath}/mc_rtc.yaml"
      ]
      ++ lib.optionals isDevel (map (cfg: "${localInstallPath}/${cfg}") devel-cfg.configs)
      ++ cfg.configs;
    in
    ''
          mkdir -p ${localInstallPath}
          echo "Generating local mc_rtc.yaml in ${localPath}/mc_rtc.yaml..."
          cat <<EOF > ${localPath}/mc_rtc.yaml
      ---
      # This mc_rtc.yaml file was generated from the mc-rtc-superbuild-standalone nix shell
      # Generated on: $(date)

      # ${lib.optionalString (cfg.MainRobot or null != null) "MainRobot: ${cfg.MainRobot}"}
      # ${lib.optionalString (cfg.Enabled or null != null) "Enabled: [${cfg.Enabled}]"}
      # ${lib.optionalString (cfg.Timestep or null != null) "Timestep: ${toString (cfg.Timestep or "")}"}

      # Dynamically generated module paths
      # FIXME: should only be lib/ or lib64/ but not both
      ControllerModulePaths: [${
        toYamlList (
          (map (p: "${p}/lib64/mc_controller") controllers) ++ (map (p: "${p}/lib/mc_controller") controllers)
        )
      }]
      RobotModulePaths: [${
        toYamlList ((map (p: "${p}/lib64/mc_robots") robots) ++ (map (p: "${p}/lib/mc_robots") robots))
      }]
      ObserverModulePaths: [${
        toYamlList (
          (map (p: "${p}/lib64/mc_observers") observers) ++ (map (p: "${p}/lib/mc_observers") observers)
        )
      }]
      GlobalPluginPaths: [${
        toYamlList ((map (p: "${p}/lib64/mc_plugins") plugins) ++ (map (p: "${p}/lib/mc_plugins") plugins))
      }]

      # Ignore ~/.config/mc_rtc/mc_rtc.yaml
      LoadUserConfiguration: false
      EOF

          export MC_RTC_PATH=${pkgs.mc-rtc}
          export MC_RTC_JEKYLL_PLUGINS=${pkgs.mc-rtc}/share/doc/mc-rtc/jekyll/plugins
          export MC_RTC_LIB=${pkgs.mc-rtc}/lib
          export MC_RTC_BIN=${pkgs.mc-rtc}/bin
          export MC_RTC_PKGCONFIG=${pkgs.mc-rtc}/lib/pkgconfig
          export MC_RTC_CONTROLLER_CONFIG=${pkgs.lib.concatStringsSep ":" configs}

          export PATH=$MC_RTC_BIN:$PATH
          export LD_LIBRARY_PATH=${lib.optionalString isDevel "${localInstallPath}/lib:${localInstallPath}/lib64:"}$MC_RTC_LIB:$LD_LIBRARY_PATH
          export PKG_CONFIG_PATH=$MC_RTC_PKGCONFIG:$PKG_CONFIG_PATH

          export TMP=/tmp
          export TMPDIR=/tmp
          export TEMP=/tmp
          export TEMPDIR=/tmp

          # FIXME this flag gets too huge and gcc fails
          export NIX_CFLAGS_COMPILE=""

          # FIXME we might need to run ros2 daemon stop && ros2 daemon start
          export ROS_DOMAIN_ID=100

          echo "${line}"
          echo "${title}"
          echo "${line}"
          echo ""

          echo "The following convenience environment variables are set:"
          env | grep '^MC_RTC_'
          echo ""

          echo "Runtime dependencies (store paths):"
          echo "Robot modules:"
          for robot in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") cfg.robots)}; do
            echo "  $robot"
          done
          echo "Plugins:"
          for plugin in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") cfg.plugins)}; do
            echo "  $plugin"
          done
          echo "Observers:"
          for observer in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") cfg.observers)}; do
            echo "  $observer"
          done
          echo "Controllers:"
          for controller in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") cfg.controllers)}; do
            echo "  $controller"
          done
          echo "Apps:"
          for app in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") cfg.apps)}; do
            echo "  $app"
          done
          echo ""
          echo "mc_rtc will use the following configuration files $MC_RTC_CONTROLLER_CONFIG"

          ${lib.optionalString isDevel "
    echo ''
    echo 'This is a development shell, the controller has not been built automatically, build it with:'
    echo 'cmake -B build -DCMAKE_INSTALL_PREFX=${relativeLocalPath}/install'
    echo 'cmake --build build --target install'
    "}

          export MC_RTC_DISABLE_CONVEX_GENERATION_PATCH="ON"
          echo ""
          echo "warning:"
          echo "- MC_RTC_DISABLE_CONVEX_GENERATION_PATCH is set to ON, this will disable convex hull generation in mc_rtc"
    '';
}
