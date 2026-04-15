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
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_h1";
    rev = "e9e5c4b1220d68229600824ad8a34f32b2f76dc0";
    hash = "sha256-dUf7TLxwJEWsumJrWz497AYfu3WI2zIyN27OvWLE2IQ=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    h1-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Unitree H1 RobotModule for mc-rtc";
    homepage = "https://github.com/isri-aist/mc_h1";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
