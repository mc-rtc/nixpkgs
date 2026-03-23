{ stdenv, lib, fetchurl, cmake, gfortran, eigen }:

stdenv.mkDerivation rec {
  pname = "eigen-quadprog";
  version = "1.1.4";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/eigen-quadprog/releases/download/v${version}/eigen-quadprog-v${version}.tar.gz";
    sha256 = "68f34c237daaa9bd6abce8fcc2a3a53e459332eefb2c22e05529293f00a53a2f";
  };

  nativeBuildInputs = [ cmake gfortran ];
  propagatedBuildInputs = [ eigen ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "eigen-quadprog allow to use the quadprog QP solver with the Eigen3 library";
    homepage    = "https://github.com/jrl-umi3218/eigen-quadprog";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
