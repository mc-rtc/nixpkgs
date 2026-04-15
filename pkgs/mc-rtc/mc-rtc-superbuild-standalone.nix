# The main purpose of this derivation is to provide an mc_rtc environment
# with runtime dependencies available, e.g robot modules, controllers, observers and plugins
#
# This is achieved by:
# - declaring the runtime dependencies in either robots, controllers, observers and plugins list
# - this derivation generates and mc_rtc.yaml configuration with runtime path to these dependencies
#   e.g in ControllerModulePaths, ObserverModulePaths, etc
{
  stdenv,
  lib,
  writeTextFile,
  mc-rtc,
  superbuildArgs ? { },
  ...
}:

let
  cfg = superbuildArgs // {
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

  # Helper to build YAML lists
  toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;

  traceGroup =
    name: pkgs:
    if cfg.traceRuntimeDependencies or false then
      map (p: builtins.trace "${cfg.pname} ${name}: ${toString p}" p) pkgs
    else
      pkgs;

  default_mc_rtc_yaml = writeTextFile {
    name = "mc_rtc.yaml";
    destination = "/etc/mc_rtc.yaml";
    text = ''
      ---
      # This mc_rtc.yaml file was generated from the mc-rtc-superbuild-standalone nix derivation (pname: ${cfg.pname})

      ${lib.optionalString (cfg.MainRobot or null != null) "MainRobot: ${cfg.MainRobot}\n"}
      ${lib.optionalString (cfg.Enabled or null != null) "Enabled: [${cfg.Enabled}]\n"}
      ${lib.optionalString (cfg.Timestep or null != null) "Timestep: ${toString (cfg.Timestep or "")}\n"}

      # Dynamically generated module paths
      ControllerModulePaths: [${toYamlList (map (p: "${p}/lib/mc_controller") (cfg.controllers or [ ]))}]
      RobotModulePaths: [${toYamlList (map (p: "${p}/lib/mc_robots") (cfg.robots or [ ]))}]
      ObserverModulePaths: [${toYamlList (map (p: "${p}/lib/mc_observers") (cfg.observers or [ ]))}]
      GlobalPluginPaths: [${toYamlList (map (p: "${p}/lib/mc_plugins") (cfg.plugins or [ ]))}]

      # Ignore ~/.config/mc_rtc/mc_rtc.yaml so that even in impure mode it does not interfere
      LoadUserConfiguration: false
    '';
  };
in

stdenv.mkDerivation {
  pname = builtins.trace "pname: ${cfg.pname}" cfg.pname;
  version = mc-rtc.version;
  src = null;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontWrapQtApps = true;

  propagatedBuildInputs = [
    mc-rtc
  ]
  ++ traceGroup "apps" (cfg.apps or [ ])
  ++ traceGroup "robots" (cfg.robots or [ ])
  ++ traceGroup "plugins" (cfg.plugins or [ ])
  ++ traceGroup "controllers" (cfg.controllers or [ ])
  ++ traceGroup "observers" (cfg.observers or [ ]);

  installPhase = ''
    mkdir -p $out/etc
    cp ${default_mc_rtc_yaml}/etc/mc_rtc.yaml $out/etc
  '';

  passthru = {
    inherit mc-rtc;
    superbuildArgs = cfg;
  };

  meta = mc-rtc.meta // {
    description =
      mc-rtc.meta.description + " (meta-package with robots, controllers, observers, plugins)";
  };

  # Set MC_RTC_CONTROLLER_CONFIG to point to the generated YAML
  # shellHook = ''
  #   export MC_RTC_CONTROLLER_CONFIG="$out/etc/mc_rtc.yaml"
  #   echo "MC_RTC_CONTROLLER_CONFIG set to $MC_RTC_CONTROLLER_CONFIG"
  # '';
}
