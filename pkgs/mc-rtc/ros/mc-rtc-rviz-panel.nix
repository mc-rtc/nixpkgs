{
  lib,
  buildRosPackage,
  ament-cmake,
  fetchFromGitHub,
  mc-rtc,
  qt5,
  qwt,
  libGL,
  libGLU,
  rviz2,
  rclcpp,
  visualization-msgs,
  tf2-ros,
  ros2cli,
  ros2launch,
  ros2run,
  useLocal ? false,
  localWorkspace ? null,
}:

let
  pname = "mc-rtc-rviz-panel";
  version = "1.6.1";
  localSrc = "${localWorkspace}/mc_rtc_ros";
  fetched =
    if useLocal then
      builtins.trace "Using local workspace for mc-rtc-rviz-panel: ${localSrc}" (
        builtins.path {
          path = "${localSrc}";
          name = "${pname}-src";
        }
      )
    else
      fetchFromGitHub {
        owner = "jrl-umi3218";
        repo = "mc_rtc_ros";
        rev = "d769df946c38f8a5befc2fe790fdba9ac739d566"; # TODO: release mc_rtc_ros
        sha256 = "sha256-Gmxv/nYKGcK9G1r0i08kLzTc2Dj8qCAQA/S0bic1LKA=";
      };
  # fetchFromGitHub {
  #   owner = "arntanguy";
  #   repo = "mc_rtc_ros";
  #   rev = "topic/nix";
  #   hash = "sha256-Gmxv/nYKGcK9G1r0i08kLzTc2Dj8qCAQA/S0bic1LKA=";
  # };
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
    qt5.qtbase
    qwt
    libGL
    libGLU
    ros2cli
    ros2run
    ros2launch
  ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  meta = {
    description = "Tools for the mc_rtc framework built around ROS (rviz panel, etc)";
    homepage = "https://github.com/jrl-umi3218/mc_rtc_ros";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
