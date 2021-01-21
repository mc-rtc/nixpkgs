{ stdenv, fetchurl, cmake, gfortran, eigen }:

stdenv.mkDerivation {
  pname = "eigen-quadprog";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/eigen-quadprog/releases/download/v1.1.0/eigen-quadprog-v1.1.0.tar.gz";
    sha256 = "14mghl5j23fwr78rs2d0vywnslcahscbs1igrkz2888v1c4arq1i";
  };

  nativeBuildInputs = [ cmake gfortran ];
  propagatedBuildInputs = [ eigen ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "eigen-quadprog allow to use the quadprog QP solver with the Eigen3 library";
    homepage    = "https://github.com/jrl-umi3218/eigen-quadprog";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
