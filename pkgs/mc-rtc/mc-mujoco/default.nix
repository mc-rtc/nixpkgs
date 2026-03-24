{
stdenv, lib, fetchgit,
makeWrapper,
mc-mujoco-robots,
cmake, mc-rtc, mujoco, jrl-cmakemodules
, libtorch-bin # for RL examples, should be an option
# XXX see if all of these are really necessary
,    libXrandr ,    libXinerama ,    libXcursor ,    libX11 ,    libXi ,    libXext
,    glew
,     glfw3
, mc-rtc-imgui
, imguizmo
, useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mc-mujoco";
  version = "0.0.0";

  dontBuild = true;

  src = if useLocal then
      builtins.trace "Using local workspace for mc-mujoco: ${localWorkspace}/mc_mujoco"
      (builtins.path {
        path = "${localWorkspace}/mc_mujoco";
        name = "mc-mujoco-src";
      })
    else
      fetchgit {
        url = "https://github.com/arntanguy/mc_mujoco.git";
        # tag = "v${finalAttrs.version}";
        # future v2.0.0 version once https://github.com/rohanpsingh/mc_mujoco/pull/98 is merged
        rev = "45b3fe8587c753daf435c6afa1383744e4e82e45";
        sha256 = "sha256-4+5tzLPmKImu6x8WYXN/k91ksDJD3HcyN08AkJh2ZOo=";
        fetchSubmodules = true;
      };

  nativeBuildInputs = [ cmake jrl-cmakemodules makeWrapper ];
  propagatedBuildInputs =
    [
      mc-rtc
      mc-rtc-imgui
      imguizmo
      mujoco
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
    homepage    = "https://github.com/jrl-umi3218/mc_mujoco";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
