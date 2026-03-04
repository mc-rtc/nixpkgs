# The main purpose of this derivation is to provide an mc_rtc environment
# with runtime dependencies available, e.g robot modules, controllers, observers and plugins
# 
# This is achieved by:
# - declaring the runtime dependencies in either robots, controllers, observers and plugins list
# - this derivation generates and mc_rtc.yaml configuration with runtime path to these dependencies
#   e.g in ControllerModulePaths, ObserverModulePaths, etc
{ stdenv, lib, writeTextFile
, mc-rtc
, MainRobot ? "JVRC1" # default robot module name
, Enabled ? "CoM" # default controller
, Timestep ? 0.005 # default timestep
, configs ? [] # extra paths to mc_rtc.yaml
, robots ? []
, controllers ? []
, observers ? []
, plugins ? []
, apps ? []
}:

let
  # Helper to build YAML lists
  toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;

  default_mc_rtc_yaml = writeTextFile {
    name = "mc_rtc.yaml";
    destination = "/etc/mc_rtc.yaml";
    text = ''
      ---
      ###################################
      # Default configuration of mc_rtc #
      ###################################
      # This file contains the default configuration of mc_rtc
      #
      # You may overwrite any of these settings in
      # - Linux/MacOS: $HOME/.config/mc_rtc/mc_rtc.yaml
      # - Windows:     %APPDATA%/mc_rtc/mc_rtc.conf
      #
      # For further details, refer to https://jrl-umi3218.github.io/mc_rtc/tutorials/introduction/configuration.html

      MainRobot: ${MainRobot}
      Enabled: [${Enabled}]
      Timestep: ${toString Timestep}
      InitAttitudeFromSensor: false
      InitAttitudeSensor: ""
      Log: true
      LogTemplate: mc-control
      GUIServer:
        Enable: true
        Timestep: 0.05
        IPC: {}
        TCP:
          Host: "*"
          Ports: [4242, 4343]
      VerboseLoader: false

      # Dynamically generated module paths
      ControllerModulePaths: [${toYamlList (map (p: "${p}/lib/mc_controller") (controllers))}]
      RobotModulePaths: [${toYamlList (map (p: "${p}/lib/mc_robots") (robots))}]
      # RobotModulePaths: [${toYamlList (["/home/arnaud/devel/mc-rtc-nix/install/lib64/mc_robots"] ++ (map (p: "${p}/lib/mc_robots") (robots)))}]
      ObserverModulePaths: [${toYamlList (map (p: "${p}/lib/mc_observers") (observers))}]
      GlobalPluginPaths: [${toYamlList (map (p: "${p}/lib/mc_plugins") (plugins))}]
      ClearControllerModulePath: false
      ClearRobotModulePath: false
      ClearObserverModulePath: false
      ClearGlobalPluginPath: false
    '';
  };
in

stdenv.mkDerivation {
  pname = "mc-rtc-meta";
  version = mc-rtc.version;
  src = null;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontWrapQtApps = true;

  propagatedBuildInputs = [ mc-rtc ] ++ apps ++ robots ++ plugins ++ controllers ++ observers;

  installPhase = ''
    mkdir -p $out/etc
    cp ${default_mc_rtc_yaml}/etc/mc_rtc.yaml $out/etc
  '';

  passthru = {
    inherit mc-rtc robots controllers observers plugins apps configs;
  };

  meta = mc-rtc.meta // {
    description = mc-rtc.meta.description + " (meta-package with robots, controllers, observers, plugins)";
  };

  # Set MC_RTC_CONTROLLER_CONFIG to point to the generated YAML
  shellHook = ''
    export MC_RTC_CONTROLLER_CONFIG="$out/etc/mc_rtc.yaml"
    echo "MC_RTC_CONTROLLER_CONFIG set to $MC_RTC_CONTROLLER_CONFIG"
  '';
}
