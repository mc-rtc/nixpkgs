{
  stdenv,
  lib,
  cmake,
  with-ros ? false,
  ament-cmake,
  buildRosPackage,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "rhps1-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src = builtins.fetchGit {
    url = "git@github.com:isri-aist/rhps1_description";
    # Release v1.0.0
    rev = "fd50b0d3424a926b8ad78b983389573b0453c88a";
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
    description = "rhps1 urdf and data";
    homepage = "https://github.com/isri-aist/mc_rhps1";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
