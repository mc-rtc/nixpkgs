{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "1.0.0";
  pname = "jvrc1-mj-description";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "jvrc_mj_description";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uLrXuYI2w+fg5a/WOZfs8kj5QB3NT35sziN3YsDmRmg=";
  };

  nativeBuildInputs = [ cmake ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    "-DHONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "JVRC1 simulation robot model mc_mujoco";
    homepage = "https://github.com/jrl-umi3218/jvrc_env_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
