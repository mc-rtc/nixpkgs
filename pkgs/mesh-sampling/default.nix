{ stdenv, lib, fetchgit, 
cmake, qhull, assimp, cli11, eigen,
useLocal ? false, localWorkspace ? null,
} :

stdenv.mkDerivation {
  pname = "mesh-sampling";
  version = "1.0.0";

  src = if useLocal then
      builtins.trace "Using local workspace for mesh-sampling: ${localWorkspace}/mesh_sampling"
      (builtins.path {
        path = "${localWorkspace}/mesh_sampling";
        name = "mesh-sampling-src";
      })
    else
      # TODO: release mesh-sampling
      fetchgit {
        url = "https://github.com/jrl-umi3218/mesh_sampling";
        rev = "4dc2f91e3a5625670bffdc6f59cadd16cad48c3d";
        sha256 = "sha256-ZhVdLWOjkRYTeTPPfGO3It4VdQbKT0MPRbzBaNnzMHE=";
      };

  nativeBuildInputs = [ cmake cli11 ];
  propagatedBuildInputs = [ qhull assimp eigen ];

  cmakeFlags = [
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Samplers to obtain pointclouds from CAD meshes ";
    homepage    = "https://github.com/jrl-umi3218/mesh_sampling";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
