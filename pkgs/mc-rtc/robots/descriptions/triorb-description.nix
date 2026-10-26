{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  with-ros ? false,
  ament-cmake,
  buildRosPackage,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "triorb-description";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_triorb_description";
    tag = "v1.0.0";
    hash = "sha256-iHZqafE5caHfGKCRHuonckZethYXd72Iapoc3bxa7bg=";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];
  propagatedBuildInputs = [ ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    (lib.cmakeBool "DISABLE_ROS" (!with-ros))
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  doCheck = false;

  meta = with lib; {
    description = "triorb-description urdf and data";
    homepage = "https://github.com/isri-aist/mc_triorb_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
