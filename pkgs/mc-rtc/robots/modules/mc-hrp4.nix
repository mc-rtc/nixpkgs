{
  stdenv,
  lib,
  cmake,
  mc-rtc,
  hrp4-description,
}:

let

  hrp4-description' = hrp4-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-hrp4";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@github.com:isri-aist/mc-hrp4";
    # Release v1.0.0
    rev = "c5e3888ed191ed9461ff2aa91d4409a22458441e";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hrp4-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  passthru = {
    mujocoRobots = [ "hrp4-mj-description" ];
  };

  doCheck = false;

  meta = with lib; {
    description = "HRP4 RobotModule for mc-rtc";
    homepage = "https://gite.lirmm.fr/mc-hrp4/mc-hrp4";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
