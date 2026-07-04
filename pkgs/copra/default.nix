{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  boost,
  eigen-qld,
  eigen-quadprog,
  jrl-cmakemodules,
}:

stdenv.mkDerivation rec {
  pname = "copra";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "copra";
    tag = "v${version}";
    hash = "sha256-KD7Fu10JEkgVXjsfC6zE028U3yBJw/cFvW9o8NEHCVM=";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    boost
    eigen-qld
    eigen-quadprog
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Copra (Control & preview algorithms) is a C++ library implementing linear model predictive control. It relies on quadratic programming (QP) solvers.";
    homepage = "https://github.com/jrl-umi3218/copra";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
