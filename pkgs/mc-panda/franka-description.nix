{ lib
, buildRosPackage, ament-cmake
, fetchFromGitHub, libfranka
, xacro
, useLocal ? false, localWorkspace ? null
}:

buildRosPackage {
  pname = "franka_description";
  version = "2.4.0";

  src = if useLocal then
    builtins.trace "Using local workspace for franka_description: ${localWorkspace}/franka_description"
    (builtins.path {
      path = "${localWorkspace}/franka_description";
      name = "franka_description-src";
    })
  else
    fetchFromGitHub {
      owner = "frankarobotics";
      repo = "franka_description";
      rev = "2.4.0"; # tag name
      sha256 = "sha256-a0Qqt4DXQa8imGMHXwDHFxO1uyooZ4SHuuXI+A+lqMg=";
    };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake ];
  nativeBuildInputs = [ ament-cmake ];
  propagatedBuildInputs = [ libfranka xacro ];

  meta = {
    description = "URDF, meshes, and other description files for Franka robots";
    homepage    = "https://github.com/frankarobotics/franka_description";
    license     = lib.licenses.asl20;
    platforms   = lib.platforms.linux;
    maintainers = [ ];
  };
}
