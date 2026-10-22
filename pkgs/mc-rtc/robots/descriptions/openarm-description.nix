{
  lib,
  fetchFromGitHub,
  xacro,
  ament-cmake,
  ament-lint-auto,
  buildRosPackage,
}:
buildRosPackage {
  pname = "openarm-description";
  version = "unreleased"; # > 1.0.4
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "enactic";
    repo = "openarm_description";
    rev = "6f0de1cba743920e74e6b88ae5e29084d99123ce";
    hash = "sha256-t+qO8PYCKhxqQK+7p24iAwQYThTQ16tyNpGzhv+J8Eg=";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = [
    ament-cmake
    ament-lint-auto
    xacro
  ];
  propagatedBuildInputs = [ ];

  # cmakeFlags = lib.optional (!with-ros) "-DDISABLE_ROS=ON" ++ [
  #   "-DBUILD_TESTING=OFF"
  # ];

  doCheck = true;

  meta = with lib; {
    description = "URDF/xacro description files for the OpenArm robot system";
    homepage = "https://github.com/enactic/openarm_description";
    license = licenses.apache20;
    platforms = platforms.all;
  };
}
