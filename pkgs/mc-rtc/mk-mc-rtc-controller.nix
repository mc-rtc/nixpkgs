/**
  # mkMcRtcController

  A wrapper for `stdenv.mkDerivation` that adds mc-rtc-specific metadata, generates a `mc_rtc.yaml` configuration file in the Nix store, and exposes all mc-rtc-related attributes under a single `mc-rtc` attribute set in `passthru`.

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
    passthru.mc-rtc = {
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
  - `mc-rtc` (attribute set): mc-rtc-specific metadata.
    - `plugins` (list): List of plugin derivations or names.
    - `observers` (list): List of observer derivations or names.
    - `controller` (attribute set): Controller configuration (e.g., `Enabled`, `MainRobot`).
    - `suggests` (attribute set): Suggested robots and apps.

  ## Output

  The returned derivation has a `passthru.mc-rtc` attribute set containing:
  - `plugins`
  - `observers`
  - `controller`
  - `suggests`
  - `mc-rtcYaml`: Path to the generated `mc_rtc.yaml` file in the Nix store.
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
}:

# excepts mc-rtc in passthru
{
  passthru ? { },
  ...
}@args:

let
  mc-rtc = passthru.mc-rtc;
  isStrOrDrv = x: lib.isString x || lib.isDerivation x;

  assertValidMcRtc =
    mc-rtc:
    lib.assertMsg (lib.all isStrOrDrv (
      mc-rtc.plugins or [ ]
    )) "mc-rtc.plugins must be a list of strings or derivations"
    && lib.assertMsg (lib.all lib.isString (
      mc-rtc.observers or [ ]
    )) "mc-rtc.observers must be a list of strings"
    && lib.assertMsg (lib.all isStrOrDrv (
      (mc-rtc.suggests or { }).robots or [ ]
    )) "mc-rtc.suggests.robots must be a list of strings or derivations"
    && lib.assertMsg (lib.all isStrOrDrv (
      (mc-rtc.suggests or { }).apps or [ ]
    )) "mc-rtc.suggests.apps must be a list of strings or derivations"
    && lib.assertMsg (lib.all isStrOrDrv (
      mc-rtc.runApps or [ ]
    )) "mc-rtc.runApps must be a list of strings or derivations";

  args' = removeAttrs args [ "mc-rtc" ];
in
stdenv.mkDerivation (
  args'
  // {
    passthru = {
      mc-rtc = mc-rtc // {
        isController = true;
      };
    };
    __asserts = assertValidMcRtc mc-rtc;
  }
)
