{ stdenv, lib, fetchurl, cmake, gfortran, eigen }:

stdenv.mkDerivation {
  pname = "eigen-qld";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/eigen-qld/releases/download/v1.2.1/eigen-qld-v1.2.1.tar.gz";
    sha256 = "1hlicwyzj477vhcvdkj09lgn9xf44irdv4wrcgx5r2254bq783k8";
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
    description = "eigen-qld allow to use the QLD QP solver with the Eigen3 library";
    homepage    = "https://github.com/jrl-umi3218/eigen-qld";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
