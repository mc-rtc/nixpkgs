{
  lib,
  buildRosPackage,
  ament-cmake,
  fetchFromGitHub,
  mc-rtc,
  qt6Packages,
  libGL,
  libGLU,
  rviz2,
  rclcpp,
  visualization-msgs,
  tf2-ros,
  ros2cli,
  ros2launch,
  ros2run,
}:

let
  pname = "mc-rtc-rviz-panel";
  version = "1.8.2";
  fetched = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc_ros";
    tag = "v1.8.2";
    hash = "sha256-UrxFFZZyqTKdOakCs4ZCf38+CF9ZUq/IYB+ZVEYfFTg=";
  };
in
buildRosPackage {
  pname = "${pname}";
  version = "${version}";

  src = "${fetched}/mc_rtc_rviz_panel";

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake ];
  nativeBuildInputs = [ ament-cmake ];
  propagatedBuildInputs = [
    mc-rtc
    rclcpp
    rviz2
    visualization-msgs
    tf2-ros
    qt6Packages.qtbase
    qt6Packages.qwt
    libGL
    libGLU
    ros2cli
    ros2run
    ros2launch
  ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  passthru = {
    inherit fetched;
  };

  meta = {
    description = "Tools for the mc_rtc framework built around ROS (rviz panel, etc)";
    homepage = "https://github.com/jrl-umi3218/mc_rtc_ros";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
