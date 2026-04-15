{
  lib,
  buildRosPackage,
  ament-cmake,
  runtimeShell,
  fetchFromGitHub,
  mc-rtc-rviz-panel,
  ros2cli,
  ros2launch,
  ros2run,
  ros2topic,
  useLocal ? false,
  localWorkspace ? null,
}:

let
  pname = "mc-rtc-ticker";
  version = "1.6.1";
  localSrc = "${localWorkspace}/mc_rtc_ros";
  fetched =
    if useLocal then
      builtins.trace "Using local workspace for mc-rtc-ticker: ${localSrc}" (
        builtins.path {
          path = "${localSrc}";
          name = "${pname}-src";
        }
      )
    else
      # fetchFromGitHub {
      #   owner = "jrl-umi3218";
      #   repo = "mc_rtc_ros";
      #   rev = "227917d348971b3ba39e7dcef0df4ca65c6bf511";
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

  src = "${fetched}/mc_rtc_ticker";

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
