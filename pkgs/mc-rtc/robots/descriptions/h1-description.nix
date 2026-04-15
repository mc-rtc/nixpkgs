{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  with-ros ? false,
  ament-cmake,
  buildRosPackage,
  useLocal ? false,
  localWorkspace ? null,
}:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "h1-description";
  version = "1.0.0";
  separateDebugInfo = false;

  src =
    if useLocal then
      builtins.trace "Using local workspace for h1-description: ${localWorkspace}/h1_description" (
        builtins.path {
          path = "${localWorkspace}/h1_description";
          name = "h1-description-src";
        }
      )
    else
      fetchFromGitHub {
        owner = "isri-aist";
        repo = "h1_description";
        rev = "v1.0.0";
        hash = "sha256-dNZWX/vqE7EUxtw5qNbwx92LaQTlvnzhq1WLRmGMnrQ=";
      };

  buildType = "ament_cmake";
  nativeBuildInputs = if with-ros then [ ament-cmake ] else [ cmake ];
  propagatedBuildInputs = [ ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = lib.optional (!with-ros) "-DDISABLE_ROS=ON" ++ [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "h1 urdf and data";
    homepage = "https://github.com/isri-aist/h1_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
