{ stdenv, lib, fetchgit, cmake, ament-cmake,
with-ros ? false, buildRosPackage,
useLocal ? false, localWorkspace ? null }:

let
  version = "1.0.8"; # TODO release
  pname = "jvrc-description";
  srcPath = "${localWorkspace}/jvrc_description";
in
(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "${pname}";
  version = "${version}";
  separateDebugInfo = false;
  postInstall = "touch $out";

  src = if useLocal then
        builtins.trace "Using local workspace for ${pname}: ${srcPath}"
        (builtins.path {
          path = "${srcPath}";
          name = "${pname}-src";
        })
      else
        # TODO: release
        fetchgit { # master
          url = "https://github.com/jrl-umi3218/jvrc_description";
          rev = "80a2aacca2dc1e3aa3d590bbe991a4ef14d54e56";
          sha256 = "sha256-/CNO8GTDVUkrj8VsezEGEMGodwQISgIa1XVhfiziy5w=";
          fetchSubmodules = true;
        };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
  ];

  doCheck = true;

  meta = with lib; {
    description = "Data for mc_rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_env_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
