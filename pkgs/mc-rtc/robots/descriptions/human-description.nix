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
  pname = "human-description";
  version = "0.0.0";
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "human_description";
    rev = "ec5665aa6078909eeedee173cf0717cdeac8ba07";
    hash = "sha256-lXMJksekuC+xjc3t6wNDyC1UiWW+4QAPwIive7twFF0=";
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
    description = "Human model ROS description package customized for mc_rtc";
    homepage = "https://github.com/jrl-umi3218/human_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
