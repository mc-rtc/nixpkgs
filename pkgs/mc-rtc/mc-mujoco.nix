{ stdenv, lib, fetchFromGitHub,
cmake, mc-rtc, mujoco, jrl-cmakemodules
, libtorch-bin # for RL examples
,    libXrandr
,    libXinerama
,    libXcursor
,    libX11
,    libXi
,    libXext
,    glew
,     glfw3
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
      fetchFromGitHub {
        owner = "rohanpsingh";
        repo = "mc_mujoco";
        # tag = "v${finalAttrs.version}";
        # future v2.0.0 version once https://github.com/jrl-umi3218/mc_mujoco/pull/2 is merged
        rev = "c1746934c1998312bb50b7505af0430d93da5bf7";
        hash = "sha256-m6itmywPqnBpX4usJmlJO5DNmquoU3ogiyyCueArUSA=";
      };

  nativeBuildInputs = [ cmake jrl-cmakemodules ];
  propagatedBuildInputs =
    [
      mc-rtc
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
  ];

  doCheck = false;

  meta = with lib; {
    description = "Plugin to update some parameters of a robot model live or from configuration ";
    homepage    = "https://github.com/jrl-umi3218/mc_mujoco";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
