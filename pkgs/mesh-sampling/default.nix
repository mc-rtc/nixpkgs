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
    tag = "v1.1.0";
    hash = "sha256-hZ8v42g0+Kw0aQtOa9id8WQ/pwDMpn8QxxBXVXpPpJU=";
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
    "-DINSTALL_DOCUMENTATION=OFF"
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
