
{ stdenv, lib, fetchurl, cmake, boost, eigen-qld, eigen-quadprog }:

stdenv.mkDerivation {
  pname = "copra";
  version = "1.2.2";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/copra/releases/download/v1.2.2/copra-v1.2.2.tar.gz";
    sha256 = "1765z58rqgikkf9kp7f59skx45xbhlab6kxdp2kyvnqhn953gmvr";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost eigen-qld eigen-quadprog ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Copra (Control & preview algorithms) is a C++ library implementing linear model predictive control. It relies on quadratic programming (QP) solvers.";
    homepage    = "https://github.com/jrl-umi3218/copra";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
