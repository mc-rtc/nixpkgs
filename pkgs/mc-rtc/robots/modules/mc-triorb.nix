{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  triorb-description,
}:

let

  triorb-description' = triorb-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-triorb";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_triorb";
    tag = "v1.0.0";
    hash = "sha256-cLpEOd0wTKKsn7meY98mfV0c1x0ZIKk7tDzBvyosEi8=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    triorb-description'
    mc-rtc
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  doCheck = false;

  meta = with lib; {
    description = "triorb RobotModule for mc-rtc";
    homepage = "https://github.com/isri-aist/mc_triorb";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
