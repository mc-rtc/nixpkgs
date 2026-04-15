{
  stdenv,
  lib,
  cmake,
  eigen-qld,
  eigen-quadprog,
  boost,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "tvm";
  version = "0.9.2";

  # master as of 2021.01.21
  # src = fetchurl {
  #   url = "https://github.com/jrl-umi3218/tvm/releases/download/v0.9.2/tvm-v0.9.2.tar.gz";
  #   sha256 = "0s9sixkz1jns6yisrdzvsm6anz6b1f1h1xp0bbi81acb0r6ss9cv";
  # };
  # master as of 21/13/2025, Release 0.9.3
  src = fetchgit {
    url = "https://github.com/arntanguy/tvm";
    rev = "67d09664e34db3dc8ce3d03ed77449eb552124ff";
    sha256 = "mZ40sjGG56PNgeXcXpHzyNJqmX7yProgFQ09WC1sUSs=";
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
