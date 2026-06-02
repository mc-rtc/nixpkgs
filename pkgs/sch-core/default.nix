{
  lib,
  stdenv,
  cmake,
  eigen,
  doxygen,
  boost,
  fetchgit,
  jrl-cmakemodules,
}:

stdenv.mkDerivation {
  pname = "sch-core";
  version = "1.4.4";

  # there is still a submodule for shared tests
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/sch-core";
    rev = "7dd530898d1041e3c985a2450a4066510399b9c6";
    hash = "sha256-8RFl+JivzyWZ/aIuaBUSDrHGE/r17N7chHF3520Agrc=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    eigen
    boost
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=ON"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "sch-core: Effective proximity queries";
    homepage = "https://github.com/jrl-umi3218/sch-core";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
