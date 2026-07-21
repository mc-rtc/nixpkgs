{
  mkMcRtcController,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  socat,
  picocom,
  screen,
  minicom,
  mc-panda-lirmm,
  pkg-config,
}:

mkMcRtcController {
  pname = "panda-prosthesis";
  version = "1.0.0";

  # TODO: release panda-prosthesis
  src = fetchFromGitHub {
    owner = "rolkneematics";
    repo = "panda_prosthesis";
    rev = "1653b020ae5ea207659fecc4ec0b0eaff65e369a";
    hash = "sha256-ZOaSpVhhxuWGaRaE5JSgpc05FptT6eX8A07/yhdCi1k=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  propagatedBuildInputs = [
    mc-rtc
    mc-panda-lirmm
    socat
    picocom
    screen
    minicom # make serial communication debugging tools available
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  passthru.mc-rtc = {
    robots = [
      "mc-panda"
      "mc-panda-lirmm"
      "panda-prosthesis"
    ];
    plugins = [ "panda-prosthesis" ];
    config = "lib/mc_controller/etc/panda_prosthesis/mc_rtc.yaml";

    devel = {
      robots = [ "panda-prosthesis" ];
      plugins = [ "panda-prosthesis" ];
      config = "lib64/mc_controller/etc/panda_prosthesis/mc_rtc.yaml";
    };

    suggests = {
      apps = [
        "mc-rtc-ticker"
        "mc-rtc-magnum"
      ];
    };

    runApps = [
      "mc-rtc-ticker"
      "mc-rtc-magnum"
    ];
  };

  meta = with lib; {
    description = "Panda RobotModule for mc-rtc";
    homepage = "https://github.com/jrl-umi3218/mc_panda";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
