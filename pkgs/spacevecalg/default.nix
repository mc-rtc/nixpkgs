{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  eigen,
  boost,
  fetchFromGitHub,
}:

let
  version = "1.2.9";
in
stdenv.mkDerivation rec {
  pname = "spacevecalg";
  inherit version;

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "SpaceVecAlg";
    rev = "cfe9af9068829f5e57fa8fe48f48852ceff52f03";
    hash = "sha256-Mvl7/venZgaqVo7BLJwk8nfl+Ng9lhHewZc8v1X8u00=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    eigen
    boost
    jrl-cmakemodules
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Spatial Vector Algebra with the Eigen library";
    homepage = "https://github.com/jrl-umi3218/SpaceVecAlg";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
