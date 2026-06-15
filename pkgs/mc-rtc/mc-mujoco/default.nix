{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  mc-mujoco-robots,
  cmake,
  jrl-cmakemodules,
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

stdenv.mkDerivation (_finalAttrs: {
  pname = "mc-mujoco";
  version = "0.0.0";

  dontBuild = true;

  src = fetchFromGitHub {
    owner = "arntanguy";
    repo = "mc_mujoco";
    tag = "1d17567c2264b32aceb3c77841765c0409a1e97";
    hash = "sha256-h1TPFQ4qxrAk3bKdY7evZq8sRld8lIJHQKogLOiSF8I=";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
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
