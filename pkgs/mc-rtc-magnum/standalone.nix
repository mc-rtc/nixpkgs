{ stdenv, lib,
makeWrapper,
fetchgit,
cmake,
mc-rtc-imgui,
corrade,
magnum,
magnum-integration,
magnum-plugins,
magnum-with-plugins,
imguizmo,
useLocal ? false, localWorkspace ? null }:

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
      path = "${localWorkspace}/mc_rtc-magnum-standalone";
      name = "mc_rtc-magnum-src";
    })
  else
    fetchgit {
      url = "https://github.com/mc-rtc/mc_rtc-magnum.git";
      # topic/nix
      # https://github.com/mc-rtc/mc_rtc-magnum/pull/4
      rev = "8f21d05f6e277151368b2593533c36535eb1750d";
      sha256 = "sha256-skQ0sCbPoaS8IBzsW6+e29Hk7KvQRWZ78rlOsMspuf4=";
      fetchSubmodules = true;
    };

  nativeBuildInputs = [ cmake makeWrapper ];
  dontBuild = true;
  buildInputs = [ 
    mc-rtc-imgui
    # magnum
    # magnum-integration
    # magnum-plugins
    imguizmo
    magnum-with-plugins
  ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  # See https://github.com/glfw/glfw/issues/2839
  postInstall = ''
    wrapProgram $out/bin/mc-rtc-magnum \
      --set XDG_SESSION_TYPE "" \
      --set WAYLAND_DISPLAY ""
  '';

  cmakeFlags = [
    "-DMAGNUM_WITH_PLUGINS_LIBDIR=${magnum-with-plugins}/lib/magnum/importers"
  ];

  meta = with lib; {
    description = "Magnum-based standalone viewer for mc-rtc";
    homepage = "https://github.com/mc-rtc/mc_rtc-magnum";
    license     = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
