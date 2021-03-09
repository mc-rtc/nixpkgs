{ stdenv, lib, fetchgit, cmake, eigen-qld, eigen-quadprog, boost }:

stdenv.mkDerivation {
  pname = "tvm";
  version = "1.0.0";

  # master as of 2021.01.21
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/tvm/";
    rev = "9b273feb05575a39e4b6fab45e17c4d090c2d292";
    sha256 = "1n049b1vkwg2yff5pvq7vlvp73msqqb74f0v7k7mm8wyixdwg8y9";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen-qld eigen-quadprog boost ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DTVM_WITH_QLD=ON"
    "-DTVM_WITH_QUADPROG=ON"
    "-DTVM_WITH_ROBOT=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Tasks with Variable Management";
    homepage    = "https://github.com/jrl-umi3218/tvm";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
