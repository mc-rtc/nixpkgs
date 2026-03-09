{ useLocal ? false, localWorkspace ? null, fetchgit }:

let
  version = "2.14.1";
  src = if useLocal then
    builtins.trace "Using local workspace for mc_rtc: ${localWorkspace}/mc_rtc"
    (builtins.path {
      path = "${localWorkspace}/mc_rtc";
      name = "mc_rtc-src";
    })
  else
    fetchgit {
      url = "https://github.com/arntanguy/mc_rtc";
      rev = "315afbb6925fe88575422a4ca1700f1b2208722f";
      fetchSubmodules = true;
      sha256 = "sha256-lZyLlHOaaQ9cl5DwNGWA6MA+dTnaD97JvdOPrjLeOZc=";
    };
in
{
  inherit version src;
}
