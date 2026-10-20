{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  h1-description,
}:

let

  h1-description' = h1-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-h1";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_h1";
    tag = "v1.1.0";
    hash = "sha256-19AAvMG2QTXRhKS+C6KiOWuABrPQ6HKx5ik8V432+xg=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    h1-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  passthru = {
    mujocoRobots = [ "h1-mj-description" ];
  };

  doCheck = false;

  meta = with lib; {
    description = "Unitree H1 RobotModule for mc-rtc";
    homepage = "https://github.com/isri-aist/mc_h1";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
