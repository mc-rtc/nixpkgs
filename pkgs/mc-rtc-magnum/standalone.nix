{
  stdenv,
  lib,
  makeWrapper,
  fetchFromGitHub,
  cmake,
  mc-rtc-imgui,
  magnum-with-plugins,
  imguizmo,
}:

# TODO: modularize the build of mc_rtc-magnum instead of using submodules
stdenv.mkDerivation {
  pname = "mc-rtc-magnum";
  version = "main";

  # nix branch on official remote
  src = fetchFromGitHub {
    owner = "mc-rtc";
    repo = "mc_rtc-magnum";
    rev = "a700fedc432bf1c453f6e13a26fc7dfd8f38ff78";
    hash = "sha256-NvIFuR31Niy+NhIkeW6yQCgQkydBc+JFeIVp5nszpc0=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];
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
    license = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
