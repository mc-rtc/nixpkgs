{ lib
, buildRosPackage, ament-cmake
, fetchFromGitHub
, mc-rtc
, mc-rtc-ticker
, qt5
, qwt
, libGL
, libGLU
, rviz2
, rclcpp
, visualization-msgs
, tf2-ros
, ros2cli
, ros2launch
, ros2run
, useLocal ? false, localWorkspace ? null
}:

let
  pname = "mc-rtc-rviz-panel";
  version = "1.6.1";
  localSrc = "${localWorkspace}/mc_rtc_ros";
  fetched =  if useLocal then
    builtins.trace "Using local workspace for mc-rtc-rviz-panel: ${localSrc}"
    (builtins.path {
      path = "${localSrc}";
      name = "${pname}-src";
    })
  else
    # fetchFromGitHub {
    #   owner = "jrl-umi3218";
    #   repo = "mc_rtc_ros";
    #   rev = "227917d348971b3ba39e7dcef0df4ca65c6bf511"; # TODO: release mc_rtc_ros
    #   sha256 = "sha256-40gtvLRzFi7Rd9BwiX3P/OWqH2fUCuZoUO53zYJdwzc=";
    # };
    fetchFromGitHub {
      owner = "arntanguy";
      repo = "mc_rtc_ros";
      rev = "topic/nix";
      hash = "sha256-Gmxv/nYKGcK9G1r0i08kLzTc2Dj8qCAQA/S0bic1LKA=";
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
    mc-rtc-ticker
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
    homepage    = "https://github.com/jrl-umi3218/mc_rtc_ros";
    license     = lib.licenses.bsd2;
    platforms   = lib.platforms.linux;
    maintainers = [];
  };
}
