{
  lib,
  fetchFromGitHub,
  ament-cmake,
  buildRosPackage,
  xacro,
}:

buildRosPackage {
  pname = "ur-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src = fetchFromGitHub {
    owner = "UniversalRobots";
    repo = "Universal_Robots_ROS2_Description";
    # topic/humble as of 2026-03-26
    rev = "50e20dd9259d69674cbfbbf36eab87a87c6eb287";
    hash = "sha256-wElH6h1bDjDBLPp6Tiqkbuk1mtlPOcqQXAnINztsYnk=";
  };

  buildType = "ament_cmake";
  nativeBuildInputs = [ ament-cmake ];
  propagatedBuildInputs = [ xacro ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  doCheck = false;

  meta = with lib; {
    description = "ur robot urdf and data";
    homepage = "https://github.com/isri-aist/mc_ur_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
