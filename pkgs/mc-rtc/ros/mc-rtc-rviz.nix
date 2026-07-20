{
  lib,
  buildRosPackage,
  ament-cmake,
  runtimeShell,
  mc-rtc-rviz-panel,
  ros2cli,
  ros2launch,
  ros2run,
  ros2topic,
}:

buildRosPackage {
  pname = "mc-rtc-rviz";
  version = "${mc-rtc-rviz-panel.version}";

  src = "${mc-rtc-rviz-panel.fetched}/mc_rtc_ticker";

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake ];
  nativeBuildInputs = [ ament-cmake ];
  propagatedBuildInputs = [
    mc-rtc-rviz-panel
    ros2cli
    ros2run
    ros2topic
    ros2launch
  ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  # convenience script to launch rviz with a simple command
  postInstall = ''
    mkdir -p $out/bin
    cat > $out/bin/mc-rtc-rviz <<EOF
    #!${runtimeShell}
    exec rviz2 -d $out/share/mc_rtc_ticker/launch/display.rviz "\$@"
    EOF
    chmod +x $out/bin/mc-rtc-rviz
  '';

  meta = {
    description = "Ticker utility for mc_rtc, installs display.rviz";
    homepage = "https://github.com/jrl-umi3218/mc_rtc_ros";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
