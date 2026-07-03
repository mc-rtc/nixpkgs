{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  with-ros ? true,
  ament-cmake,
  buildRosPackage,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "pepper-description";
  version = "0.0.0";
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "pepper_description";
    rev = "b953b44c39935dc4c9d4cffa15e733850a33e5df";
    hash = "sha256-/owu1vAkQoqUDV8+5T7DtDXPE0vK4qN4Be8vMkwyc1o=";
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
    description = "pepper description package for mc_rtc";
    homepage = "https://github.com/jrl-umi3218/pepper_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
