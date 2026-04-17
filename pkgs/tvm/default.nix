{
  stdenv,
  lib,
  cmake,
  eigen-qld,
  eigen-quadprog,
  boost,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "tvm";
  version = "0.9.2";

  # master
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "tvm";
    rev = "538f367bfab8621d0a315c6bca58a7186fda2832";
    hash = "sha256-aWv1KLiY4TJ6lplRt/YZQVGxxPcy61MLJi+TppKmmZU=";
  };

  nativeBuildInputs = [ cmake ];
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
