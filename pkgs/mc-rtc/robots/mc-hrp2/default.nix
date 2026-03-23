{ stdenv, lib, fetchgit, cmake, mc-rtc, hrp2-description, useLocal ? false, localWorkspace ? null } :

let

hrp2-description' = hrp2-description.override {
  with-ros = mc-rtc.with-ros;
};

in

stdenv.mkDerivation {
  pname = "mc-hrp2";
  version = "1.0.0";

  # TODO: release mc-hrp2
  src = if useLocal then
    builtins.trace "Using local workspace for mc-hrp2: ${localWorkspace}/mc-hrp2"
    (builtins.path {
      path = "${localWorkspace}/mc-hrp2";
      name = "mc-hrp2-src";
    })
  else
    builtins.fetchGit {
      url = "git@github.com:isri-aist/mc-hrp2";
      rev = "58d64f62e6031571f9fff9b6211f6dcc2d93535b";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ hrp2-description' mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP2DRC RobotModule for mc-rtc";
    homepage    = "https://gite.lirmm.fr/mc-hrp2/mc-hrp2";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
