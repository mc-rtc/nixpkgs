# The main purpose of this derivation is to provide an mc_rtc environment
# with runtime dependencies available, e.g robot modules, controllers, observers and plugins
{
  stdenv,
  symlinkJoin,
  rsync,
  mc-rtc,
  MainRobot ? "JVRC1",
  Enabled ? "CoM",
  Timestep ? 0.005,
  configs ? [ ],
  robots ? [ ],
  controllers ? [ ],
  observers ? [ ],
  plugins ? [ ],
  apps ? [ ],
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

  buildInputs = [
    rsync
    merged
  ];

  installPhase = ''
    mkdir $out
    # exclude mc_rtc.yaml from the symlinkJoin, as we want to override it
    rsync -a --exclude=etc/mc_rtc.yaml ${merged}/ $out/
    # allow to write a modified mc_rtc.yaml
    chmod u+w $out/etc

    # Override mc_rtc's default mc_rtc.yaml configuration to provide:
    # - the runtime paths to the merged derivation (controllers, plugins, etc)
    # - the controller to run, the timestep
    # - which main robot to use
    #
    # Note that mc_rtc will load its own default configuration from the mc-rtc derivation
    # This mc_rtc.yaml in the merged path will be loaded as an extra configuration provided by MC_RTC_CONTROLLER_CONFIG environment variable, and merged by mc_rtc using its configuration merging rules.
    cat > $out/etc/mc_rtc.yaml <<EOF
    Timestep: ${toString Timestep}
    MainRobot: ${MainRobot}
    Enabled: [${Enabled}]
    ClearControllerModulePath: true
    ClearRobotModulePath: true
    ClearObserverModulePath: true
    ClearGlobalPluginPath: true
    ControllerModulePaths: ["$out/lib/mc_controller"]
    RobotModulePaths: ["$out/lib/mc_robots"]
    ObserverModulePaths: ["$out/lib/mc_observers"]
    GlobalPluginPaths: ["$out/lib/mc_plugins"]
    EOF
  '';

  shellHook = ''
    export MC_RTC_CONTROLLER_CONFIG="$out/etc/mc_rtc.yaml"
    echo "MC_RTC_CONTROLLER_CONFIG set to $MC_RTC_CONTROLLER_CONFIG"
  '';

  passthru = {
    inherit
      mc-rtc
      robots
      controllers
      observers
      plugins
      apps
      configs
      ;
  };

  meta = mc-rtc.meta // {
    description =
      mc-rtc.meta.description + " (meta-package with robots, controllers, observers, plugins)";
  };
}
