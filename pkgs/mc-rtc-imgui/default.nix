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

  # head of nix branch (for stanalone install)
  # https://github.com/mc-rtc/mc_rtc-imgui/tree/nix
  src = fetchFromGitHub {
    owner = "mc-rtc";
    repo = "mc_rtc-imgui";
    rev = "6ac125c00ca5e18c7da80e0049dc5697f4f36a23";
    hash = "sha256-J9uQpfn08Yv5ROxQmxHYwiVRdvZsVOp2klZmgnw90Bg=";
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
