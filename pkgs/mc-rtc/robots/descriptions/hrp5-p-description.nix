{ stdenv, lib, cmake, with-ros ? false, ament-cmake, buildRosPackage }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "hrp5-p-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src = builtins.fetchGit {
    url = "git@github.com:isri-aist/hrp5_p_description";
    rev = "40af0c413474c937df31447dc631f73a75fbd2f8";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];
  propagatedBuildInputs = [];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP5P urdf and data";
    homepage    = "https://github.com/isri-aist/hrp5_p_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}

