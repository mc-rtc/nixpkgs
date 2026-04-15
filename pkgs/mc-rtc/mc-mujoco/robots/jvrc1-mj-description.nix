{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  useLocal ? false,
  localWorkspace ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "1.0.0";
  pname = "jvrc1-mj-description";
  srcPath = "${localWorkspace}/jvrc_mj_description";

  src =
    if useLocal then
      builtins.trace
        "Using local workspace for ${finalAttrs.pname}: ${localWorkspace}/jvrc_mj_description"
        (
          builtins.path {
            path = "${localWorkspace}/jvrc_mj_description";
            name = "${finalAttrs.pname}-src";
          }
        )
    else
      fetchFromGitHub {
        owner = "isri-aist";
        repo = "jvrc_mj_description";
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
    description = "JVRC1 simulation robot model mc_mujoco";
    homepage = "https://github.com/jrl-umi3218/jvrc_env_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
