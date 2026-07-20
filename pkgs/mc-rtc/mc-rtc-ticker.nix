/**
  Convenience derivation to run mc_rtc_ticker through nix run
*/

# {
#   lib,
#   mc-rtc,
#   # writeShellApplication
#   buildRosPackage,
# rosPackages,
# }:
# writeShellApplication {
#   name = "mc-rtc-ticker";
#   runtimeInputs = [ mc-rtc ];
#   text = ''
#     exec ${mc-rtc}/bin/mc_rtc_ticker "$@"
#   '';
#   meta = with lib; {
#     description = "Run mc_rtc_ticker from mc-rtc";
#     platforms = platforms.linux;
#   };
# }
{
  lib,
  writeShellApplication,
  rosPackages,
  mc-rtc,
  rosDistro ? "jazzy",
}:

let
  runtimeInputs = [ mc-rtc ];
  rosEnv = rosPackages.${rosDistro}.buildEnv {
    paths = runtimeInputs;
  };
in

writeShellApplication {
  name = "mc-rtc-ticker";
  runtimeInputs = if mc-rtc.with-ros then [ rosEnv ] else runtimeInputs;
  text = ''
    exec mc_rtc_ticker "$@"
  '';
  meta = with lib; {
    description = "Run mc_rtc_ticker with ROS environment (no sourcing needed)";
    platforms = platforms.linux;
    mainProgram = "mc-rtc-ticker";
  };
}
