{ stdenv, lib, fetchgit, cmake,
eigen,
useLocal ? false, localWorkspace ? null
}:

# eigen-fmt derivation, avoiding the use of PID build system
stdenv.mkDerivation (finalAttrs:{
  pname = "eigen-fmt";
  version = "1.0.4";

  src = if useLocal then
      builtins.trace "Using local workspace for eigen-fmt: ${localWorkspace}/eigen-fmt"
      (builtins.path {
        path = "${localWorkspace}/${finalAttrs.pname}";
        name = "${finalAttrs.pname}-src";
      })
    else
      fetchgit {
        url = "https://gite.lirmm.fr/rpc/utils/eigen-fmt.git";
        # rev = "f736848c2d825d7a537c97dfbaa618a92c83cce3";
        tag = "v${finalAttrs.version}";
        sha256 = "sha256-5Qukk12EvkS4hG3ew488hrkr/85gaXjvz6uYq7HkkaI=";
      };

  # To avoid the PID build system dependency, manually provide the cmake export logic
  patchPhase = ''
    mkdir cmake
    cp ${./CMakeLists.txt} ./CMakeLists.txt
    cp -r ${./cmake/eigen-fmtConfig.cmake.in} ./cmake/eigen-fmtConfig.cmake.in
  '';

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen ];

  doCheck = false;

  meta = with lib; {
    description = "Provides custom formatters for eigen types to be used with the {fmt} library";
    homepage    = "https://gite.lirmm.fr/rpc/utils/eigen-fmt";
    license     = licenses.cecill-2_1;
    platforms   = platforms.all;
  };
})
