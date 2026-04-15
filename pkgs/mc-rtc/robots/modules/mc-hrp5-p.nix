{
  stdenv,
  lib,
  cmake,
  mc-rtc,
  hrp5-p-description,
}:

let

  hrp5-p-description' = hrp5-p-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-hrp5-p";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@github.com:isri-aist/mc_hrp5_p";
    rev = "f6837bad37c39ea7de7feaa56189fb0489e6836b";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hrp5-p-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP5-P RobotModule for mc-rtc";
    homepage = "https://gite.lirmm.fr/mc-hrp5/mc-hrp5_p";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
