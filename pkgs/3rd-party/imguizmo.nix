# filepath: pkgs/3rd-party/imguizmo/imguizmo.nix
{
  stdenv,
  lib,
  fetchgit,
  cmake,
  imgui,
  jrl-cmakemodules,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "imguizmo";
  version = "0.0.0";

  dontBuild = true;

  src =
    # fetchFromGitHub {
    #   owner = "CedricGuillemet";
    #   repo = "ImGuizmo";
    #   rev = "a15acd87a3f3241a29ea1363ceafc680dca3a96b";
    #   hash = "sha256-BnnFgHQv4FSc20zyJ2nYICA9dE0Q1hU0+NR9t5pi2cY=";
    # };
    fetchgit {
      url = "https://github.com/arntanguy/ImGuizmo.git";
      rev = "48087b6ac7f10a914ba95f59611d8287c5f90bc2";
      hash = "sha256-JLwciNGo90vR5tsFB4z5JPvhCz38FhN9Ja/5+Ct6YPo=";
    };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    imgui
  ];

  cmakeFlags = [ ];

  doCheck = false;

  meta = with lib; {
    description = "Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui ";
    homepage = "https://github.com/CedricGuillemet/imguizmo";
    license = licenses.mit;
    platforms = platforms.all;
  };
})
