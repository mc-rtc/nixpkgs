/**
  # mkMcRtcController

  A wrapper for `stdenv.mkDerivation` that adds mc-rtc-specific metadata, generates a `mc_rtc.yaml` configuration file in the Nix store, and exposes all mc-rtc-related attributes under a single `mcRtc` attribute set in `passthru`.

  ## Usage

  ```nix
  let
    mkController = import ./pkgs/mc-rtc/mkController.nix { inherit lib pkgs; };
  in
  mkMcRtcController {
    pname = "ismpc-walking-controller";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "jrl-umi3218";
      repo = "lipm_walking_controller";
      tag = "v0.1.0";
      hash = "sha256-tPWzbxuJbJm5zlUzU8jQJSdTIOsW8mb/Ci2DOeFdr4M=";
    };
    buildInputs = [ jrl-cmakemodulesv2 ];
    nativeBuildInputs = [ cmake ];
    propagatedBuildInputs = [
      mc-rtc
      pendulum-feasibility-solver
      mc-joystick-plugin
    ];
    cmakeFlags = [
      "-DINSTALL_DOCUMENTATION=OFF"
      "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
    ];
    doCheck = true;
    meta = with lib; {
      description = "Walking controller based on linear inverted pendulum tracking";
      homepage = "https://github.com/isri-aist/ismpc_walking";
      license = licenses.bsd2;
      platforms = platforms.all;
    };
    mcRtc = {
      plugins = [
        footsteps-planner-plugin
        mc-joystick-plugin
      ];
      observers = [ "mc-state-observation" ];
      controller = {
        Enabled = "ismpc_walking";
        MainRobot = "JVRC1";
      };
      suggests = {
        robots = [
          "mc-hrp4"
          "mc-hrp2"
          "mc-hrp5-p"
          "mc-rhps1"
          "mc-hrp4cr"
        ];
        apps = [ "mc-mujoco" ];
      };
    };
  }
  ```

  ## Arguments

  - All standard `stdenv.mkDerivation` arguments are supported.
  - `mcRtc` (attribute set): mc-rtc-specific metadata.
    - `plugins` (list): List of plugin derivations or names.
    - `observers` (list): List of observer derivations or names.
    - `controller` (attribute set): Controller configuration (e.g., `Enabled`, `MainRobot`).
    - `suggests` (attribute set): Suggested robots and apps.

  ## Output

  The returned derivation has a `passthru.mcRtc` attribute set containing:
  - `plugins`
  - `observers`
  - `controller`
  - `suggests`
  - `mcRtcYaml`: Path to the generated `mc_rtc.yaml` file in the Nix store.
  - `shellHook`: A shell hook that sets `MC_RTC_CONTROLLER_CONFIG` and `LD_LIBRARY_PATH`.

  ## Example

  To use the generated YAML in a shell:

  ```sh
  nix develop .#ismpc-walking-controller
  # The environment variable MC_RTC_CONTROLLER_CONFIG will point to the YAML file.
  ```
*/
{
  stdenv,
  lib,
  pkgs,
}:

{
  mcRtc ? { },
  ...
}@args:

let
  controller = mcRtc.controller or { };

  mcRtcYamlTemplate = pkgs.writeText "${args.pname or "controller"}-mc_rtc.yaml.in" ''
    ---
    ${lib.optionalString (controller ? MainRobot) "MainRobot: \"${controller.MainRobot}\""}
    ${lib.optionalString (controller ? Enabled) "Enabled: \"${controller.Enabled}\""}
    ControllerModulePaths: ["@out@/lib/mc_controller"]
    RobotModulePaths: ["@out@/lib/mc_robots"]
    ObserverModulePaths: ["@out@/lib/mc_observers"]
    GlobalPluginPaths: ["@out@/lib/mc_plugins"]
    LoadUserConfiguration: false
  '';
  args' = builtins.removeAttrs args [ "mcRtc" ];
in
stdenv.mkDerivation (
  args'
  // {
    passthru = {
      mcRtc = mcRtc // {
        # access it as ${drv}/${mcRtcYaml}
        mcRtcYaml = "share/mc_rtc.yaml";
      };
    };

    postInstall = ''
      mkdir -p $out/share
      sed "s|@out@|$out|g" ${mcRtcYamlTemplate} > $out/share/mc_rtc.yaml
    '';
  }
)
