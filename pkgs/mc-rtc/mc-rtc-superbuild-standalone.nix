# The main purpose of this derivation is to provide an mc_rtc environment
# with runtime dependencies available, e.g robot modules, controllers, observers and plugins
# 
# This is achieved by:
# - declaring the runtime dependencies in either robots, controllers, observers and plugins list
# - this derivation generates and mc_rtc.yaml configuration with runtime path to these dependencies
#   e.g in ControllerModulePaths, ObserverModulePaths, etc
{ stdenv, lib, writeTextFile
, mc-rtc
, MainRobot ? null # default robot module name
, Enabled ? null # default controller
, Timestep ? null # default timestep
, configs ? [] # extra paths to mc_rtc.yaml
, robots ? []
, controllers ? []
, observers ? []
, plugins ? []
, apps ? []
, pname ? "mc-rtc-superbuild-standalone"
}:

let
  # Helper to build YAML lists
  toYamlList = paths: lib.concatMapStringsSep ", " (p: "\"${p}\"") paths;

  default_mc_rtc_yaml = writeTextFile {
    name = "mc_rtc.yaml";
    destination = "/etc/mc_rtc.yaml";
    text = ''
      ---
      # This mc_rtc.yaml file was generated from the mc-rtc-superbuild-standalone nix derivation (pname: ${pname})

      ${lib.optionalString (MainRobot != null) "MainRobot: ${MainRobot}\n"}
      ${lib.optionalString (Enabled != null) "Enabled: [${Enabled}]\n"}
      ${lib.optionalString (Timestep != null) "Timestep: ${toString Timestep}\n"}

      # Dynamically generated module paths
      ControllerModulePaths: [${toYamlList (map (p: "${p}/lib/mc_controller") (controllers))}]
      RobotModulePaths: [${toYamlList (map (p: "${p}/lib/mc_robots") (robots))}]
      ObserverModulePaths: [${toYamlList (map (p: "${p}/lib/mc_observers") (observers))}]
      GlobalPluginPaths: [${toYamlList (map (p: "${p}/lib/mc_plugins") (plugins))}]

      # Ignore ~/.config/mc_rtc/mc_rtc.yaml so that even in impure mode it does not interfere
      LoadUserConfiguration: false
    '';
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "${pname}";
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
  # shellHook = ''
  #   export MC_RTC_CONTROLLER_CONFIG="$out/etc/mc_rtc.yaml"
  #   echo "MC_RTC_CONTROLLER_CONFIG set to $MC_RTC_CONTROLLER_CONFIG"
  # '';
})
