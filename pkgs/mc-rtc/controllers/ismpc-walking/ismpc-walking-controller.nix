{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodulesv2,
  mc-rtc,
  pendulum-feasibility-solver,
  footsteps-planner-plugin,
  mc-joystick-plugin,
}:

stdenv.mkDerivation rec {
  pname = "ismpc-walking-controller";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "lipm_walking_controller";
    tag = "v${version}";
    hash = "sha256-tPWzbxuJbJm5zlUzU8jQJSdTIOsW8mb/Ci2DOeFdr4M=";
  };

  buildInputs = [ jrl-cmakemodulesv2 ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    pendulum-feasibility-solver
    mc-joystick-plugin
  ];

  # XXX(mc-rtc-passthru)
  passthru = {
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
}
