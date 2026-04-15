{
  stdenv,
  lib,
  fetchgit,
  cmake,
  mc-rtc,
  copra,
  useLocal ? false,
  localWorkspace ? null,
}:

let
  version = "1.6.0";
  localFolder = "lipm_walking_controller";
in
stdenv.mkDerivation {
  pname = "lipm-walking-controller";
  version = "${version}";

  # master branch as of 2021.01.25
  src =
    if useLocal then
      builtins.trace "Using local workspace for lipm-walking-controller: ${localWorkspace}/${localFolder}"
        (
          builtins.path {
            path = "${localWorkspace}/${localFolder}";
            name = "lipm-walking-controller-src";
          }
        )
    else
      fetchgit {
        url = "https://github.com/jrl-umi3218/lipm_walking_controller";
        rev = "e28e9552faff0ee110fcc3d6ce11dc6bb4759e31";
        sha256 = "sha256-nj1XWy9XHbk9oP1H2mZsFqmBJ1lnNG0CnMEA20VG6eQ";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    copra
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Walking controller based on linear inverted pendulum tracking";
    homepage = "https://github.com/jrl-umi3218/lipm_walking_controller";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
