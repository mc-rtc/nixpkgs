{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  mc-rtc,
  imgui,
  implot,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "mc-rtc-imgui";
  version = "1.0.0";

  dontBuild = true;

  src =
    # head of nix branch (for stanalone install)
    fetchFromGitHub {
      owner = "mc-rtc";
      repo = "mc_rtc-imgui";
      rev = "4ab4c6d7add120284f870f0ac51541802c18c461";
      hash = "sha256-qKZmySycr/MSju71cTFpn1fcESxujvDtN1JRYJ78Ykg=";
    };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    mc-rtc
    imgui
    implot
  ];

  doCheck = false;

  meta = with lib; {
    description = "Base GUI client for mc_rtc using Dear ImGui";
    homepage = "https://github.com/mc-rtc/mc_rtc-imgui";
    license = licenses.bsd2; # FIXME set licence in repository
    platforms = platforms.all;
  };
})
