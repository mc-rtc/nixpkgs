{
  stdenv,
  mkMcRtcController,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  copra,
}:

mkMcRtcController rec {
  pname = "lipm-walking-controller";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "lipm_walking_controller";
    tag = "v${version}";
    hash = "sha256-tPWzbxuJbJm5zlUzU8jQJSdTIOsW8mb/Ci2DOeFdr4M=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    copra
  ];

  cmakeFlags = [
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = true;

  passthru.mc-rtc = {
    plugins = [ ]; # todo add external footstep planner plugins
    observers = [ "mc-state-observation" ];
    controller = {
      Enabled = "LIPMWalking";
      MainRobot = "JVRC1";
    };
    suggests = {
      robots = [
        "mc-hrp4"
        "mc-hrp2"
        "mc-hrp5-p"
        "mc-hrp4cr"
        # FIXME(mc-rhps1): too large for now
        # "mc-rhps1"
      ];
      apps = [
        "mc-rtc-ticker"
        "mc-rtc-magnum"
      ]
      ++ lib.optional (!stdenv.hostPlatform.isDarwin) "mc-mujoco";
    };
    runApps =
      lib.optional (!stdenv.hostPlatform.isDarwin) "mc-mujoco"
      ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
        "mc-rtc-ticker"
        "mc-rtc-magnum"
      ];
  };

  meta = with lib; {
    description = "Walking controller based on linear inverted pendulum tracking";
    homepage = "https://github.com/jrl-umi3218/lipm_walking_controller";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
