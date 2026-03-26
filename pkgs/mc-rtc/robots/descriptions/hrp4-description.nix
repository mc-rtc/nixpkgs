{ stdenv, lib, cmake, with-ros ? false, ament-cmake, buildRosPackage }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "hrp4-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src = builtins.fetchGit {
    url = "git@github.com:isri-aist/hrp4_description";
    # Release v1.0.0
    rev = "7fcf6c471eaca5a5018b917560b9a62e4e4aa069";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];
  propagatedBuildInputs = [];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = 
  lib.optional (!with-ros) "-DDISABLE_ROS=ON"
  ++
  [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP4 urdf and data";
    homepage    = "https://github.com/isri-aist/hrp4_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}

