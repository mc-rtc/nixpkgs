{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  with-ros ? true,
  ament-cmake,
  buildRosPackage,
  xacro,
  ur-description,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "ur5e-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_ur5e_description";
    rev = "4a3ee47d6eeb11e3f08a13f2cb5529c472244516";
    hash = "sha256-I/NL1BnvAr6Apq6/ZduxjoJ/WiUOF4v3nASJBmvFmPA=";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];
  propagatedBuildInputs = [ ur-description ] ++ lib.optionals with-ros [ xacro ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = lib.optional (!with-ros) "-DDISABLE_ROS=ON" ++ [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "UR5e robot urdf and data";
    homepage = "https://github.com/isri-aist/mc_ur5e_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
