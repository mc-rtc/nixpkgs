{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  boost,
  eigen,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "state-observation";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "state-observation";
    rev = "826249a";
    hash = "sha256-q3QeX8RkfYR6cLFinMPpgI8MaCsx+H6UMGziqYkhW5Y=";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    boost
    eigen
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_STATE_OBSERVATION_TOOLS=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Describes interfaces for state observers, and implements some observers (including linear and extended Kalman filters)";
    homepage = "https://github.com/jrl-umi3218/state-observation";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
