{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  eigen-qld,
  eigen-quadprog,
  boost,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "tvm";
  version = "0.9.2";

  # master
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/tvm";
    rev = "538f367bfab8621d0a315c6bca58a7186fda2832";
    sha256 = "sha256-qse7emorGWqoWlmzaHNdbDiHFXrVOo3oz8Fah4AYmL8=";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    eigen-qld
    eigen-quadprog
    boost
  ];

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
    homepage = "https://github.com/jrl-umi3218/tvm";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
