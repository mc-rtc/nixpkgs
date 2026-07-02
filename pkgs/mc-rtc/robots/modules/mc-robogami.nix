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
  # src = fetchFromGitHub {
  #   owner = "anastasiabolotnikova";
  #   repo = "mc_robogami";
  #   rev = "3d026f529dead658d478e729857e031209e96ed8";
  #   hash = "sha256-8TRJi0ZLyEBxz8/iFXGt+qBu+gIs0qXyDV0Hmz1CT4I=";
  # };
  src = fetchFromGitHub {
    owner = "arntanguy";
    repo = "mc_robogami";
    rev = "2d9ce185009a17ecf7e9fa85034ec73f67f0f776";
    hash = "sha256-W9ACYU9dyPfCCDJRl99RtCx4gnaNlrmDuJayY8PcuYk=";
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
