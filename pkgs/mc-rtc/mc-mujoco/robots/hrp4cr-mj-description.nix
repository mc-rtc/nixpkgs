{ stdenv, lib, fetchFromGitHub, cmake,
useLocal ? false, localWorkspace ? null }:

stdenv.mkDerivation (finalAttrs: {
  version = "1.0.0";
  pname = "hrp4cr-mj-description";
  srcPath = if localWorkspace != null then "${localWorkspace}/hrp4cr_mj_description" else null;

  src = if useLocal then
        builtins.trace "Using local workspace for ${finalAttrs.pname}: ${finalAttrs.srcPath}"
        (builtins.path {
          path = "${finalAttrs.srcPath}";
          name = "${finalAttrs.pname}-src";
        })
      else
        fetchFromGitHub {
          owner = "isri-aist";
          repo = "hrp4cr_mj_description";
          tag = "v${finalAttrs.version}";
          hash = "";
        };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DHONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "hrp4cr simulation robot model mc_mujoco";
    homepage    = "https://github.com/jrl-umi3218/hrp4cr_env_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
