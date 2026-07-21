{
  stdenv,
  lib,
  cmake,
  mc-rtc,
  hrp2-description,
}:

let

  hrp2-description' = hrp2-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-hrp2";
  version = "1.0.0";

  # TODO: release mc-hrp2
  # src = builtins.fetchGit {
  #   url = "git@github.com:isri-aist/mc-hrp2";
  #   rev = "58d64f62e6031571f9fff9b6211f6dcc2d93535b";
  # };

  # PR https://github.com/isri-aist/mc-hrp2/pull/8
  src = builtins.fetchGit {
    url = "git@github.com:arntanguy/mc-hrp2";
    rev = "2d72cd24eda07c2cd131e53a26e20643a522261e";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hrp2-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  passthru = {
    # FIXME does not exist
    # mujocoRobots = [ "hrp2-mj-description" ];
  };

  doCheck = false;

  meta = with lib; {
    description = "HRP2DRC RobotModule for mc-rtc";
    homepage = "https://gite.lirmm.fr/mc-hrp2/mc-hrp2";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
