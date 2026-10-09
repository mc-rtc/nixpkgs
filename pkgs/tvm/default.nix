{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  eigen-qld,
  eigen-quadprog,
  with-lssol ? false,
  eigen-lssol ? null,
  boost,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = if (with-lssol && eigen-lssol != null) then "tvm-lssol" else "tvm-qld";
  version = "0.9.2";

  # master
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/tvm";
    rev = "538f367bfab8621d0a315c6bca58a7186fda2832";
    sha256 = "sha256-qse7emorGWqoWlmzaHNdbDiHFXrVOo3oz8Fah4AYmL8=";
  };

  buildInputs = [
    jrl-cmakemodules
  ];
  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    eigen-qld
    eigen-quadprog
    boost
  ]
  ++ lib.optional (with-lssol && eigen-lssol != null) eigen-lssol;

  cmakeFlags = [
    "-DTVM_WITH_QLD=ON"
    "-DTVM_WITH_QUADPROG=ON"
    (lib.cmakeBool "TVM_WITH_LSSOL" with-lssol)
    "-DTVM_WITH_ROBOT=OFF"
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Tasks with Variable Management";
    homepage = "https://github.com/jrl-umi3218/tvm";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
