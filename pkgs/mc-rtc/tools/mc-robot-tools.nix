{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  xacro,
  mc-rtc,
  mesh-sampling,
  with-bota-sensor ? false, # missing bota_driver
  with-ds4 ? true, # ok
  with-plate ? true, # ok
  with-realsense-camera ? true, # ok
  # missing robotiq_gripper https://github.com/PickNikRobotics/ros2_robotiq_gripper
  with-robotiq-gripper ? false,
  with-screw ? true,
}:

stdenv.mkDerivation {
  pname = "mc-robot-tools";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_robot_tools";
    rev = "1c4c9ce4da400e48975fa491f27ff3fba2688fb9";
    hash = "sha256-91jH8Xx8C/vUFr7qwunHL49P11CEP/SslRLH8NVHySM=";
  };

  nativeBuildInputs = [
    cmake
    xacro
  ];
  propagatedBuildInputs = [
    mc-rtc
    mesh-sampling
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_BOTA_SENSOR" with-bota-sensor)
    (lib.cmakeBool "WITH_DS4" with-ds4)
    (lib.cmakeBool "WITH_PLATE" with-plate)
    (lib.cmakeBool "WITH_REALSENSE_CAMERA" with-realsense-camera)
    (lib.cmakeBool "WITH_ROBOTIQ_GRIPPER" with-robotiq-gripper)
    (lib.cmakeBool "WITH_SCREW" with-screw)
  ];

  doCheck = false;

  meta = with lib; {
    description = "All tool modules with mc-rtc framework";
    homepage = "https://github.com/isri-aist/mc_robot_tools";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
