{ stdenv, lib, fetchgit, cmake, ament-cmake,
with-ros ? false, buildRosPackage,
useLocal ? false, localWorkspace ? null }:

let
  version = "1.0.8";
  pname = "mc-env-description";
in
(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "${pname}";
  version = "${version}";

  # TODO: remove ROSFree branch
  src =
    if useLocal then
      builtins.trace "Using local workspace for mc-env-description: ${localWorkspace}/mc_env_description"
      (builtins.path {
        path = "${localWorkspace}/mc_env_description";
        name = "${pname}-src";
      })
    else 
      if with-ros then
        builtins.trace "with-ros true: ${toString with-ros}"
        (fetchgit { # master
          url = "https://github.com/jrl-umi3218/mc_env_description";
          rev = "b55cddfead7a43217d5b179a6eca213ad94f4e65";
          sha256 = "sha256-5sjyojlG+MM4OCUmNSlEhu7FLvckk2n7oE8mFu9H7Sw=";
          fetchSubmodules = true;
        })
    else
      builtins.trace "with-ros false: ${toString with-ros}"
      (fetchgit { # master
        url = "https://github.com/jrl-umi3218/mc_env_description";
        rev = "ca84a40a0a27783c4ed63bd8f057af7ef41b33bb";
        sha256 = "sha256-ntz/u9YTWd2YuVhtRngm0qnOU8nsH0ODZ828x/Uba9s=";
        fetchSubmodules = true;
      });

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    "-DROS_VERSION=2"
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Data for mc_rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_env_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
