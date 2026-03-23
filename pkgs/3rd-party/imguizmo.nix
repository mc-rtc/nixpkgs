# filepath: pkgs/3rd-party/imguizmo/imguizmo.nix
{ stdenv, lib, fetchFromGitHub,
  cmake,
  imgui,
  jrl-cmakemodules,
  useLocal ? false,
  localWorkspace ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imguizmo";
  version = "0.0.0";

  dontBuild = true;

  src = if useLocal then
    builtins.trace "Using local workspace for imguizmo: ${localWorkspace}/ImGuizmo"
      (builtins.path {
        path = "${localWorkspace}/ImGuizmo";
        name = "imguizmo-src";
      })
    else
      fetchFromGitHub {
        owner = "CedricGuillemet";
        repo = "ImGuizmo";
        rev = "a15acd87a3f3241a29ea1363ceafc680dca3a96b";
        hash = "";
      };

  nativeBuildInputs = [ cmake jrl-cmakemodules ];
  propagatedBuildInputs = [
    imgui
  ];

  cmakeFlags = [];

  doCheck = false;

  meta = with lib; {
    description = "Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui ";
    homepage    = "https://github.com/CedricGuillemet/imguizmo";
    license     = licenses.mit;
    platforms   = platforms.all;
  };
})
