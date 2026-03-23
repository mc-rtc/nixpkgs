{ stdenv, lib, fetchgit, 
cmake, qhull, assimp, cli11, eigen, libz,
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
        # master
        rev = "466064a4e9b7718b0b90922122c6aedd4867724a";
        sha256 = "sha256-2e1Ctq/2lj2BNyxPH3VD+owYlURyIUq82D74y4nKPeg=";
      };

  nativeBuildInputs = [ cmake cli11 ];
  # XXX why is libz dependency manually required here? Either qhull or assimp should bring it
  propagatedBuildInputs = [ qhull assimp eigen libz ];

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
