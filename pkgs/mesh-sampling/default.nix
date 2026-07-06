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

stdenv.mkDerivation {
  pname = "mesh-sampling";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mesh_sampling";
    rev = "6dbc4e4c3a4ecb57df03ca2467d4451d1afcd878";
    hash = "sha256-w1z137pUR3LbkblVhfNaKBmMQytSti4HlAOJiZyH1Ms=";
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
