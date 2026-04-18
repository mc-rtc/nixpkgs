{
  stdenv,
  lib,
  cmake,
  pkg-config,
  doxygen,
  gfortran,
  boost,
  eigen,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "eigen-lssol";
  version = "0.0.0";

  src = builtins.fetchGit {
    url = "git@gite.lirmm.fr:multi-contact/eigen-lssol.git";
    # Master
    rev = "4663b177a04a2d397bb2e4e3f62ae139e911cac3";
    submodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
    gfortran
  ];
  propagatedBuildInputs = [
    eigen
    boost
  ];

  cmakeFlags = [
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  postPatch = ''
    # Require C++14 instead of C++11
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_CXX_STANDARD 11)" "set(CMAKE_CXX_STANDARD 14)"
  '';

  doCheck = true;

  meta = with lib; {
    description = "eigen-lssol allow to use the LSSOL QP solver with the Eigen3 library";
    homepage = "https://gite.lirmm.fr/multi-contact/eigen-lssol";
    license = licenses.unfree;
    platforms = platforms.all;
  };
})
