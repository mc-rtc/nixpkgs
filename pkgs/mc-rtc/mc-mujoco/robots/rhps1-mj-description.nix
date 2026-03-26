{ stdenv, lib, fetchFromGitHub, cmake,
useLocal ? false, localWorkspace ? null }:

stdenv.mkDerivation (finalAttrs: {
  version = "1.0.0";
  pname = "rhps1-mj-description";

  src = if useLocal then
        builtins.trace "Using local workspace for ${finalAttrs.pname}: ${localWorkspace}/rhps1_mj_description"
        (builtins.path {
          path = "${localWorkspace}/rhps1_mj_description";
          name = "${finalAttrs.pname}-src";
        })
      else
        builtins.fetchGit {
          url = "git@github.com:isri-aist/rhps1_mj_description";
          # Release v1.0.0
          rev = "ac2d198b21b6f431fffc2c93ad03b04f98c4135a";
        };

  nativeBuildInputs = [ cmake ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    "-DHONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "rhps1 simulation robot model mc_mujoco";
    homepage    = "https://github.com/jrl-umi3218/rhps1_env_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
