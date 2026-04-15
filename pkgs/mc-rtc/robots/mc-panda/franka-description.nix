# FIXME: unused
# See https://github.com/frankarobotics/franka_description to see how to generate the URDF models from xacro
# We would need to compile, install them, then modify mc-panda to use them. wtf frankarobotics.
{
  lib,
  buildRosPackage,
  ament-cmake,
  fetchFromGitHub,
  libfranka,
  xacro,
  useLocal ? false,
  localWorkspace ? null,
}:

buildRosPackage {
  pname = "franka_description";
  version = "2.6.0";

  src =
    if useLocal then
      builtins.trace "Using local workspace for franka_description: ${localWorkspace}/franka_description"
        (
          builtins.path {
            path = "${localWorkspace}/franka_description";
            name = "franka_description-src";
          }
        )
    else
      fetchFromGitHub {
        owner = "frankarobotics";
        repo = "franka_description";
        rev = "2.6.0"; # tag name
        sha256 = "sha256-+5IqH80KWvUb7aoHh9n0CIod5zh3q3pRQaWi62Ed8aY=";
      };

  buildType = "ament_cmake";
  nativeBuildInputs = [
    ament-cmake
    xacro
  ];
  propagatedBuildInputs = [ libfranka ];

  meta = {
    description = "URDF, meshes, and other description files for Franka robots";
    homepage = "https://github.com/frankarobotics/franka_description";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
