{
  stdenv,
  lib,
  cmake,
  boost,
  eigen,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "state-observation";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/state-observation/releases/download/v${version}/state-observation-v${version}.tar.gz";
    sha256 = "317603aebde3343c90a9ca2f4a8e9a249eaef25e156773a6eb7eab078fcc0191";
  };

  nativeBuildInputs = [ cmake ];
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
