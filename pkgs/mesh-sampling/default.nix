{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  gtest,
  cli11,
  qhull,
  assimp,
  eigen,
  libz,
}:

stdenv.mkDerivation rec {
  pname = "mesh-sampling";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mesh_sampling";
    tag = "v1.3.1";
    hash = "sha256-4/RD8uKGouyU6hI5bHQ3eJwAjS2j6QxOPtiAomXZkyg=";
  };

  buildInputs = [
    cli11
    jrl-cmakemodules
  ];
  nativeBuildInputs = [
    cmake
    gtest
  ];
  # XXX why is libz dependency manually required here? Either qhull or assimp should bring it
  propagatedBuildInputs = [
    qhull
    assimp
    eigen
    libz
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_LEGACY_QHULL_STREAM" false)
    (lib.cmakeBool "DINSTALL_DOCUMENTATION" false)
  ];

  doCheck = true;

  meta = with lib; {
    mainProgram = "mesh_sampling";
    description = "Samplers to obtain pointclouds from CAD meshes ";
    homepage = "https://github.com/jrl-umi3218/mesh_sampling";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
