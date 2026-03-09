# The main purpose of this derivation is to provide an mc_rtc environment
# with runtime dependencies available, e.g robot modules, controllers, observers and plugins
# 
# This is achieved by:
# - declaring the runtime dependencies in either robots, controllers, observers and plugins list
# - this derivation generates and mc_rtc.yaml configuration with runtime path to these dependencies
#   e.g in ControllerModulePaths, ObserverModulePaths, etc
{ stdenv, lib, writeTextFile
, symlinkJoin
, rsync
, mc-rtc
, MainRobot ? "JVRC1Toto"
, Enabled ? "CoM"
, Timestep ? 0.005
, configs ? []
, robots ? []
, controllers ? []
, observers ? []
, plugins ? []
, apps ? []
}:

let
  merged = symlinkJoin {
    name = "mc-rtc-meta-merged";
    paths = [ mc-rtc ] ++ apps ++ robots ++ plugins ++ controllers ++ observers;
  };
in
stdenv.mkDerivation {
  pname = "mc-rtc-meta";
  version = mc-rtc.version;
  src = null;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  buildInputs = [ rsync merged ];

  installPhase = ''
    mkdir $out
    #cp -r ${merged}/* $out/
    rsync -a --exclude=etc/mc_rtc.yaml ${merged}/ $out/
    chmod u+w $out/etc
    cp ${merged}/etc/mc_rtc.yaml $out/etc/mc_rtc.yaml

    # Override mc_rtc's default mc_rtc.yaml configuration to provide:
    # - the runtime paths to the merged derivation (controllers, plugins, etc)
    # - the controller to run, the timestep
    # - which main robot to use
    sed -i \
      -e "s|^Timestep:.*|Timestep: ${toString Timestep}|" \
      -e "s|^MainRobot:.*|MainRobot: ${MainRobot}|" \
      -e "s|^Enabled:.*|Enabled: [${Enabled}]|" \
      -e "s|^# ClearControllerModulePath:.*|ClearControllerModulePath: true|" \
      -e "s|^# ClearRobotModulePath:.*|ClearRobotModulePath: true|" \
      -e "s|^# ClearObserverModulePath:.*|ClearObserverModulePath: true|" \
      -e "s|^# ClearGlobalPluginPath:.*|ClearGlobalPluginPath: true|" \
      -e "s|^# ControllerModulePaths:.*|ControllerModulePaths: [\"$out/lib/mc_controller\"]|" \
      -e "s|^# RobotModulePaths:.*|RobotModulePaths: [\"$out/lib/mc_robots\"]|" \
      -e "s|^# ObserverModulePaths:.*|ObserverModulePaths: [\"$out/lib/mc_observers\"]|" \
      -e "s|^# GlobalPluginPaths:.*|GlobalPluginPaths: [\"$out/lib/mc_plugins\"]|" \
      $out/etc/mc_rtc.yaml
  '';

  shellHook = ''
    export MC_RTC_CONTROLLER_CONFIG="$out/etc/mc_rtc.yaml"
    echo "MC_RTC_CONTROLLER_CONFIG set to $MC_RTC_CONTROLLER_CONFIG"
  '';

  passthru = {
    inherit mc-rtc robots controllers observers plugins apps configs;
  };

  meta = mc-rtc.meta // {
    description = mc-rtc.meta.description + " (meta-package with robots, controllers, observers, plugins)";
  };
}
