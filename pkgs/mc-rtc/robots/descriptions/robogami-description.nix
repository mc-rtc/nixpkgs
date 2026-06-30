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
  pname = "robogami-description";
  version = "0.0.0";
  separateDebugInfo = false;

  # TODO: release
  src = fetchFromGitHub {
    owner = "anastasiabolotnikova";
    repo = "robogami_description";
    rev = "f72de9f7c61f952fac2904fa04406b2a48951862";
    hash = "sha256-rx6aboTUMVBd7E8VmKD7nownUbIQvv+0f1yizw0Ccts=";
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
    description = "robogami urdf and data";
    homepage = "https://github.com/anastasiabolotnikova/robogami_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
