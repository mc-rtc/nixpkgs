{
  mkMcRtcController,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodulesv2,
  mc-rtc,
  pendulum-feasibility-solver,
  footsteps-planner-plugin,
  mc-joystick-plugin,
}:

mkMcRtcController {
  pname = "ismpc-walking-controller";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "ismpc_walking";
    rev = "6cb5dfc280265fe06068accac79227fdc7bed39c";
    hash = "sha256-4m7o/ujtHKbonxmV57QvZ7IY4lDQVP1dBSosbZlB92Y=";
  };
  buildInputs = [ jrl-cmakemodulesv2 ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    pendulum-feasibility-solver
    mc-joystick-plugin
  ];
  cmakeFlags = [
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];
  doCheck = true;
  meta = with lib; {
    description = "Walking controller based on linear inverted pendulum tracking";
    homepage = "https://github.com/isri-aist/ismpc_walking";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
  mcRtc = {
    plugins = [
      footsteps-planner-plugin
      mc-joystick-plugin
    ];
    observers = [ "mc-state-observation" ];
    controller = {
      Enabled = "ismpc_walking";
      MainRobot = "JVRC1";
    };
    suggests = {
      robots = [
        "mc-hrp4"
        "mc-hrp2"
        "mc-hrp5-p"
        "mc-rhps1"
        "mc-hrp4cr"
      ];
      apps = [ "mc-mujoco" ];
    };
  };
}
