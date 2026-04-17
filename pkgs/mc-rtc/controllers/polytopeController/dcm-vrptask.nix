{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  eigen-quadprog,
  gram-savitzky-golay,
  jrl-cmakemodules,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "dcm-vrptask";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Hugo-L3174";
    repo = "DCM_VRPTask";
    #tag = "v${finalAttrs.version}";
    rev = "";
    hash = "";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ];
  propagatedBuildInputs = [
    mc-rtc
    gram-savitzky-golay
    eigen-quadprog
  ];

  doCheck = false;

  meta = with lib; {
    description = "DCM-VRP tracking task for mc-rtc";
    homepage = "https://github.com/Hugo-L3174/DCM_VRPTask";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
