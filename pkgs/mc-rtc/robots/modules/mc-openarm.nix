{
  lib,
  fetchFromGitHub,
  mc-rtc,
  openarm-description,
  ament-cmake,
  xacro,
  buildRosPackage,
}:

buildRosPackage {
  pname = "mc-openarm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_openarm";
    tag = "v1.0.0";
    hash = "sha256-dGDuqOQi1CI/Yr95qayGRB2/GAa3UcVs/9sx9bLi4x4=";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = [
    ament-cmake
    xacro
  ];
  propagatedBuildInputs = [
    openarm-description
    mc-rtc
  ];

  passthru = {
    # mujocoRobots = [ "openarm-mj-description" ];
  };

  doCheck = true;

  meta = with lib; {
    description = "OpenArm RobotModule for mc-rtc";
    homepage = "https://github.com/isri-aist/mc_openarm";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
