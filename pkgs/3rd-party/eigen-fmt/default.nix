{
  stdenv,
  lib,
  fetchgit,
  cmake,
  eigen,
  fmt,
  useLocal ? false,
  localWorkspace ? null,
}:

# eigen-fmt derivation, avoiding the use of PID build system
stdenv.mkDerivation (finalAttrs: {
  pname = "eigen-fmt";
  version = "1.0.4";

  src =
    if useLocal then
      builtins.trace "Using local workspace for eigen-fmt: ${localWorkspace}/eigen-fmt" (
        builtins.path {
          path = "${localWorkspace}/${finalAttrs.pname}";
          name = "${finalAttrs.pname}-src";
        }
      )
    else
      # fetchgit {
      #   url = "https://gite.lirmm.fr/rpc/utils/eigen-fmt.git";
      #   # rev = "f736848c2d825d7a537c97dfbaa618a92c83cce3";
      #   tag = "v${finalAttrs.version}";
      #   sha256 = "sha256-5Qukk12EvkS4hG3ew488hrkr/85gaXjvz6uYq7HkkaI=";
      # };
      fetchgit {
        url = "https://gite.lirmm.fr/atanguy/eigen-fmt.git";
        rev = "19f006086b2bdfadf638fcda5fb45a5a15e39d9c";
        sha256 = "sha256-JruhgYZm0WZxDN2d0uitTUNg+myQ7SWo5dX+c1vKv/M=";
      };

  # To avoid the PID build system dependency, manually provide the cmake export logic
  patchPhase = ''
    mkdir cmake
    cp ${./CMakeLists.txt} ./CMakeLists.txt
    cp -r ${./cmake/eigen-fmtConfig.cmake.in} ./cmake/eigen-fmtConfig.cmake.in
  '';

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    eigen
    fmt
  ];

  doCheck = false;

  meta = with lib; {
    description = "Provides custom formatters for eigen types to be used with the {fmt} library";
    homepage = "https://gite.lirmm.fr/rpc/utils/eigen-fmt";
    license = licenses.cecill21;
    platforms = platforms.all;
  };
})
