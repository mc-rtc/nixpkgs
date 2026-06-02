{
  stdenv,
  lib,
  cmake,
  pkg-config,
  jrl-cmakemodules,
  doxygen,
  eigen,
  boost,
  fetchFromGitHub,
  python3Packages,
}:

stdenv.mkDerivation {
  pname = "spacevecalg";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "SpaceVecAlg";
    rev = "cfe9af9068829f5e57fa8fe48f48852ceff52f03";
    hash = "sha256-Mvl7/venZgaqVo7BLJwk8nfl+Ng9lhHewZc8v1X8u00=";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
    pkg-config
    doxygen
    python3Packages.cython
    python3Packages.python
    python3Packages.distutils
    python3Packages.pytest
  ];

  propagatedBuildInputs = [
    eigen
    boost
    python3Packages.numpy
    python3Packages.eigen3-to-python
  ];

  # cmakeFlags = [
  #   "-DBUILD_TESTING=OFF"
  #   "-DINSTALL_DOCUMENTATION=OFF"
  # ];

  doCheck = true;

  meta = with lib; {
    description = "Spatial Vector Algebra with the Eigen library";
    homepage = "https://github.com/jrl-umi3218/SpaceVecAlg";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
