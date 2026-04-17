{
  stdenv,
  lib,
  fetchgit,
  cmake,
  ament-cmake,
  with-ros ? false,
  buildRosPackage,
}:

let
  version = "1.0.8"; # TODO release
  pname = "mc-int-obj-description";
in
(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "${pname}";
  version = "${version}";
  separateDebugInfo = false;

  src =
    # TODO: release
    fetchgit {
      # master
      url = "https://github.com/jrl-umi3218/mc_int_obj_description";
      rev = "b5af6dc486ec9af3413399c815c0904635d6708a";
      sha256 = "sha256-V/VxnReFTnJ5I9uJHwI1BQTDozqH2DEP01SQvkZs424=";
      fetchSubmodules = true;
    };

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
    homepage = "https://github.com/jrl-umi3218/mc_int_obj_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
