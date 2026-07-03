{
  stdenv,
  lib,
  cmake,
  with-ros ? true,
  ament-cmake,
  buildRosPackage,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "miroki-description";
  version = "0.0.0";
  separateDebugInfo = false;

  src = fetchGit {
    url = "git@github.com:isri-aist/miroki_description";
    rev = "294ccaceb61f331902c5117558ddb4af82836074";
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
    description = "miroki robot description for mc_rtc";
    homepage = "https://github.com/isri-aist/miroki_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
