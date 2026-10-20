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
  pname = "h1-description";
  version = "1.1.0";
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "h1_description";
    tag = "v1.1.0";
    hash = "sha256-wrM2rpIYcUyy0HWCOEnB73qwRR8jgkw8WMrp9irj5WA=";
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
    description = "h1 urdf and data";
    homepage = "https://github.com/isri-aist/h1_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
