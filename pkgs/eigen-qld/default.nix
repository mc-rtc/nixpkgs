{ stdenv, lib, fetchurl, cmake, gfortran, eigen }:

stdenv.mkDerivation rec {
  pname = "eigen-qld";
  version = "1.2.6";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/eigen-qld/releases/download/v${version}/eigen-qld-v${version}.tar.gz";
    sha256 = "835fca05e2274b7ae9dbe250db5f28b193e28318d55e10d354cf8d443c10fcaf";
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
