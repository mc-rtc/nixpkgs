{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  pkg-config,
  doxygen,
  gfortran,
  boost,
  eigen,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "eigen-lssol";
  version = "0.0.0";

  src = fetchGit {
    url = "git@gite.lirmm.fr:multi-contact/eigen-lssol.git";
    # Master
    rev = "af9c2cf289935da022d405b8247616b70a717e6e";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    jrl-cmakemodules
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

  doCheck = true;

  meta = with lib; {
    description = "eigen-lssol allow to use the LSSOL QP solver with the Eigen3 library";
    homepage = "https://gite.lirmm.fr/multi-contact/eigen-lssol";
    license = licenses.unfree;
    platforms = platforms.all;
  };
})
