{ stdenv, lib, fetchgit, cmake, mc-rtc, glfw, xorg, useLocal ? false, localWorkspace ? null }:

# TODO: modularize the build of mc_rtc-magnum instead of using submodules
stdenv.mkDerivation {
  pname = "mc-rtc-magnum";
  version = "main";

  # main as of 2025-25-11
  # FIXME: release mc-rtc-magnum
  # src = fetchgit {
  #   url = "https://github.com/mc-rtc/mc_rtc-magnum.git";
  #   rev = "3b4ace180e43281be717255b2629c5eb0ec2ccbb";
  #   sha256 = "sha256-6wwvyec7yfxjpa/njqsrw2k78kbsazy9+id+mp2je/8=";
  #   fetchsubmodules = true;
  # };
  src = if useLocal then
    builtins.trace "Using local workspace for mc_rtc-magnum: ${localWorkspace}/mc_rtc-magnum"
    (builtins.path {
      path = "${localWorkspace}/mc_rtc-magnum";
      name = "mc_rtc-magnum-src";
    })
  else
    fetchgit {
      url = "https://github.com/mc-rtc/mc_rtc-magnum.git";
      # topic/nix
      rev = "6b9835904e4beb2c784214d8d96e1fc0eb596799";
      sha256 = "sha256-xo8u7OEMNeNCevfH6Fj8t6dLSb7sDOftWhjqu8DwjyY=";
      fetchSubmodules = true;
    };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ 
    mc-rtc
    glfw
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
  ];

  cmakeFlags = [
  ];

  meta = with lib; {
    description = "Magnum-based standalone viewer for mc-rtc";
    homepage = "https://github.com/mc-rtc/mc_rtc-magnum";
    license     = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
