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
      rev = "3e6c1617a5e622795019b2bccd2ba259df18026f";
      hash = "sha256-KmcF5e0O2bQheTArjxaDeBQlxf3cywaFtNlxleHYsL8=";
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
