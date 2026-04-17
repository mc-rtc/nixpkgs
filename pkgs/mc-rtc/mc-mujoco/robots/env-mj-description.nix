{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "env-mj-description";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "env_mj_description";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PiSbUX7+nSk8mNLsRBQGvo+sf/XCyN9xgcsY4BweyZo=";
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
    description = "Environment robot data for mc_mujoco";
    homepage = "https://github.com/jrl-umi3218/mc_env_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
