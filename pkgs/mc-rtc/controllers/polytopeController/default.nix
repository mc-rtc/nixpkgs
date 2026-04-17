{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-dynamic-polytopes,
  mc-force-shoe-plugin,
  dcm-vrptask,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "polytopeController";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Hugo-L3174";
    repo = "polytopeController";
    tag = "v${finalAttrs.version}";
    hash = "sha256-djFHb/S6wLg8dMR4sT2tqKx5aEZxwszC2iRRnc23yiM=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-dynamic-polytopes
    mc-force-shoe-plugin
    dcm-vrptask
  ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
    "-DCMAKE_MODULE_PATH=${mc-dynamic-polytopes}/lib/cmake;${mc-force-shoe-plugin}/lib/cmake;${dcm-vrptask}/lib/cmake"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Controller to test dynamic stability approaches";
    homepage = "https://github.com/Hugo-L3174/polytopeController";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
