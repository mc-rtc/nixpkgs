{ stdenv, lib, fetchFromGitHub, cmake,
useLocal ? false, localWorkspace ? null }:

stdenv.mkDerivation (finalAttrs: {
  version = "1.0.0";
  pname = "hrp5p-mj-description";
  srcPath = "";
  separateDebugInfo = false;
  postInstall = "touch $out";

  src = if useLocal then
        builtins.trace "Using local workspace for ${finalAttrs.pname}: ${localWorkspace}/hrp5p_mj_description"
        (builtins.path {
          path = "${localWorkspace}/hrp5p_mj_description";
          name = "${finalAttrs.pname}-src";
        })
      else
        fetchFromGitHub {
          owner = "isri-aist";
          repo = "hrp5p_mj_description";
          tag = "v${finalAttrs.version}";
          hash = "sha256-uLrXuYI2w+fg5a/WOZfs8kj5QB3NT35sziN3YsDmRmg=";
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
    description = "hrp5p simulation robot model mc_mujoco";
    homepage    = "https://github.com/jrl-umi3218/hrp5p_env_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
