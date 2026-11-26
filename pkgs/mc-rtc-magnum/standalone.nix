{
  stdenv,
  lib,
  makeWrapper,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  pkg-config,
  mc-rtc-imgui,
  magnum-with-plugins,
  imguizmo,
}:

stdenv.mkDerivation {
  pname = "mc-rtc-magnum-standalone";
  version = "1.7.0-unstable-2026-11-23";

  # nix branch on official remote
  src = fetchFromGitHub {
    owner = "mc-rtc";
    repo = "mc_rtc-magnum";
    rev = "f0b651aae21a85f02a959d114e179aff51fbf743";
    hash = "sha256-Bn918sARWRzJzuwjklgORA0dOApBw9fCeOgu+HbfVtI=";
  };

  patches = [
    (fetchpatch {
      name = "update-magnum-pr";
      url = "https://patch-diff.githubusercontent.com/raw/mc-rtc/mc_rtc-magnum/pull/19.patch";
      hash = "sha256-pCNEgA2ubajY9/N9CZ5qD2zOQVlxAdfiXui6Gq06siI=";
    })
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];
  dontBuild = true;
  buildInputs = [
    pkg-config
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
  # postInstall = ''
  #   wrapProgram $out/bin/mc-rtc-magnum \
  #     --set XDG_SESSION_TYPE "" \
  #     --set WAYLAND_DISPLAY ""
  # '';

  # FIXME upstream
  # On macos plugins are built as MH_BUNDLE and we cannot link against them,
  # they are only meant to be used with dlopen
  # We can remove them on linux to for builds against dynamic libraries
  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "Magnum::AnyImageImporter" "" \
      --replace "Magnum::AnySceneImporter" "" \
      --replace "MagnumPlugins::AssimpImporter" "" \
      --replace "MagnumPlugins::StbImageImporter" ""
  ''
  + ''
    substituteInPlace src/McRtcGui.h \
      --replace '#include "MagnumClient.h"' \
                $'#include "MagnumClient.h"\n#include <Magnum/Shaders/PhongGL.h>'
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
    mainProgram = "mc-rtc-magnum";
  };
}
