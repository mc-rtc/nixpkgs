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
  pname = "g1-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "g1_description";
    rev = "v1.0.0";
    hash = "sha256-kjuMnP1qoL7LWTU55uvt9/n6KlUkUO5/rgxs1H77cV8=";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];
  propagatedBuildInputs = [ ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = lib.optional (!with-ros) "-DDISABLE_ROS=ON" ++ [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "g1 urdf and data";
    homepage = "https://github.com/isri-aist/g1_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
