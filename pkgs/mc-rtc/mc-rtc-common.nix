{ lib, useLocal ? false, localWorkspace ? null, fetchgit }:

let
  version = "2.14.1";
  src = if useLocal then
    builtins.trace "Using local workspace for mc_rtc: ${localWorkspace}/mc_rtc"
    (builtins.path {
      path = "${localWorkspace}/mc_rtc";
      name = "mc-rtc-src";
    })
  else
    fetchgit {
      url = "https://github.com/jrl-umi3218/mc_rtc";
      # PR 495 merged (HONOR_INSTALL_PREFIX)
      rev = "1d5f6da998110acba73c327831903ee933ac884f";
      fetchSubmodules = true;
      sha256 = "sha256-soiG0+SK9PmJCrPRpaJt3Ej1SSxUg9kT8UlMajwUfqg=";
    };
in
{
  inherit version src;
}
