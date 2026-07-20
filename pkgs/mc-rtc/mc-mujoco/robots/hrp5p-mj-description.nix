{
  stdenv,
  lib,
  cmake,
}:

stdenv.mkDerivation (_finalAttrs: {
  version = "1.0.0";
  pname = "hrp5p-mj-description";

  src = fetchGit {
    url = "git@github.com:isri-aist/hrp5p_mj_description";
    rev = "8d8ca2ee2a4e59080f71503e91ff65cc3937e26c";
  };

  nativeBuildInputs = [ cmake ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    "-DHONOR_INSTALL_PREFIX=ON"
  ];

  passthru = {
    robot.module = "mc-hrp5-p";
  };

  doCheck = true;

  meta = with lib; {
    description = "hrp5p simulation robot model mc_mujoco";
    homepage = "https://github.com/jrl-umi3218/hrp5p_env_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
