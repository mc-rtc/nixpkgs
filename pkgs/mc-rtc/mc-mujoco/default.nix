{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  mc-mujoco-robots,
  cmake,
  pkg-config,
  jrl-cmakemodules,
  cli11,
  mc-rtc,
  mujoco,
  pugixml,
  libtorch-bin, # for RL examples, should be an option
  # XXX see if all of these are really necessary
  libXrandr,
  libXinerama,
  libXcursor,
  libX11,
  libXi,
  libXext,
  glew,
  glfw3,
  mc-rtc-imgui,
  imguizmo,
}:

builtins.trace "building mc-mujoco against mujoco version ${mujoco.version}" stdenv.mkDerivation
  (_finalAttrs: {
    pname = "mc-mujoco";
    version = "0.0.0";

    dontBuild = true;
    dontWrapQtApps = true;

    # stanalone mc_mujoco version from
    # https://github.com/rohanpsingh/mc_mujoco/pull/98
    # we cannot merge as the standalone version cannot be easily set-up outside of Nix
    src = fetchFromGitHub {
      owner = "arntanguy";
      repo = "mc_mujoco";
      rev = "6831ab806387d1e574913eba2d573101fc9cdde7";
      hash = "sha256-TjgjJAr+VICAQox1Qwsmgz07XKhFcJ0nb5IkvuIE9eo=";
    };

    buildInputs = [
      cli11
      jrl-cmakemodules
      pkg-config
    ];
    nativeBuildInputs = [
      cmake
      makeWrapper
    ];
    propagatedBuildInputs = [
      mc-rtc
      mc-rtc-imgui
      imguizmo
      mujoco
      pugixml
      libXrandr
      libXinerama
      libXcursor
      libX11
      libXi
      libXext
      glew
      glfw3
      libtorch-bin
    ];

    cmakeFlags = [
      "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
      "-DSTANDALONE_ROBOTS=ON"
      "-DBUILD_EXAMPLES=OFF"
      "-DMC_MUJOCO_SHARE_DESTINATION=${mc-mujoco-robots}"
    ];

    # See https://github.com/glfw/glfw/issues/2839
    postInstall = ''
      wrapProgram $out/bin/mc_mujoco \
        --set XDG_SESSION_TYPE "" \
        --set WAYLAND_DISPLAY ""
    '';

    doCheck = false;

    meta = with lib; {
      mainProgram = "mc_mujoco";
      description = "Plugin to update some parameters of a robot model live or from configuration ";
      homepage = "https://github.com/jrl-umi3218/mc_mujoco";
      license = licenses.bsd2;
      platforms = platforms.all;
    };
  })
