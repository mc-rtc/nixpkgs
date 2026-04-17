{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "1.0.0";
  pname = "hrp5p-mj-description";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "hrp5p_mj_description";
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
    description = "hrp5p simulation robot model mc_mujoco";
    homepage = "https://github.com/jrl-umi3218/hrp5p_env_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
