{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  g1-description,
}:

let

  g1-description' = g1-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-g1";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_g1";
    rev = "7e35e3fc0e3e0d9e2edbabbac2c5ca7b79e93bac";
    hash = "sha256-k3A52LUzA44C/b8/ztvtbpJ4lh20f7Nzk1rOfufJrKc=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    g1-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "g1 RobotModule for mc-rtc";
    homepage = "https://github.com/isri-aist/mc_g1";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
