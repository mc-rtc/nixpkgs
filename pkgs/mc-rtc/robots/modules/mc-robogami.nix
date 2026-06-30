{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  robogami-description,
}:

let

  robogami-description' = robogami-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-robogami";
  version = "0.0.0";

  # TODO: release
  src = fetchFromGitHub {
    owner = "anastasiabolotnikova";
    repo = "mc_robogami";
    rev = "3d026f529dead658d478e729857e031209e96ed8";
    hash = "sha256-8TRJi0ZLyEBxz8/iFXGt+qBu+gIs0qXyDV0Hmz1CT4I=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    robogami-description'
    mc-rtc
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  doCheck = false;

  meta = with lib; {
    description = "robogami RobotModule for mc-rtc";
    homepage = "https://github.com/anastasiabolotnikova/mc_robogami";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
