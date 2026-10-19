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
  doxygen,
  gbenchmark,
  doxygen-awesome-css,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = if (with-lssol && eigen-lssol != null) then "tvm-lssol" else "tvm-qld";
  version = "0.9.8";

  # master
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "tvm";
    tag = "v0.9.8";
    hash = "sha256-1JgwB5je5qLVuSJJ7pn9iOe9TGKZSlWofulRl+SAHsE=";
  };

  buildInputs = [
    jrl-cmakemodules
    doxygen
    gbenchmark
    doxygen-awesome-css
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
    (lib.cmakeBool "BUILD_DOCUMENTATION" true)
    "-DTVM_WITH_QLD=ON"
    "-DTVM_WITH_QUADPROG=ON"
    (lib.cmakeBool "TVM_WITH_LSSOL" with-lssol)
    "-DTVM_WITH_ROBOT=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DDOXYGEN_AWESOME_CSS_PATH=${doxygen-awesome-css}/share/doxygen-awesome-css"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Tasks with Variable Management";
    homepage = "https://github.com/jrl-umi3218/tvm";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
