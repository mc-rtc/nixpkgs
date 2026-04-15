{
  stdenv,
  lib,
  cmake,
  with-ros ? false,
  ament-cmake,
  buildRosPackage,
  useLocal ? false,
  localWorkspace ? null,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "hrp2-description";
  version = "1.0.0";
  separateDebugInfo = false;

  # TODO: release hrp2_drc_descriptioin
  src =
    if useLocal then
      builtins.trace "Using local workspace for hrp2-description: ${localWorkspace}/hrp2_drc_description"
        (
          builtins.path {
            path = "${localWorkspace}/hrp2_drc_description";
            name = "hrp2-drc-description-src";
          }
        )
    else
      builtins.fetchGit {
        url = "git@github.com:isri-aist/hrp2_drc_description.git";
        # Commit for v1.0.0 release
        rev = "d0b4648965622e9546fbff620ece09be7e6dee8a";
      };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = lib.optional (!with-ros) "-DDISABLE_ROS=ON" ++ [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP2 urdf and data";
    homepage = "https://gite.lirmm.fr/mc-hrp2/hrp2_drc";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
