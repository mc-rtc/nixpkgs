{
  lib,
  buildRosPackage,
  fetchurl,
  colcon,
  rosidl-default-runtime,
  rosidl-default-generators,
  rosidl-typesupport-c,
  rosidl-typesupport-cpp,
  ament-cmake,
  geometry-msgs,
}:

let
  version = "1.1.2";
in
buildRosPackage {
  pname = "ros-jazzy-mc-rtc-msgs";
  version = "${version}";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/mc_rtc_msgs/releases/download/v${version}/mc_rtc_msgs-v${version}.tar.gz";
    sha256 = "sha256-NGRbolox21Ch6+LlN2aoyRd8aK2f3f2aOLQE/injxQc=";
  };

  buildType = "colcon";

  buildInputs = [
  ];
  propagatedBuildInputs = [
    rosidl-default-generators
    geometry-msgs
    rosidl-default-runtime
    rosidl-typesupport-c
    rosidl-typesupport-cpp
    ament-cmake
  ];
  nativeBuildInputs = [ colcon ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  meta = {
    description = "Common messages used by mc_rtc ROS plugin";
    license = with lib.licenses; [ bsd2 ];
  };
}
