{ stdenv, lib, cmake,
useLocal ? false, localWorkspace ? null }:

stdenv.mkDerivation (finalAttrs: {
  version = "0.0.0";
  pname = "hrp4-mj-description";

  src = if useLocal then
        builtins.trace "Using local workspace for ${finalAttrs.pname}: ${localWorkspace}/hrp4_mj_description"
        (builtins.path {
          path = "${localWorkspace}/hrp4_mj_description";
          name = "${finalAttrs.pname}-src";
        })
      else
        # XXX should we merge with https://gite.lirmm.fr/mc-hrp4/hrp4_mj_description
        # I don't remember what hugo changes were
        # TODO release
        builtins.fetchGit {
          url = "git@gite.lirmm.fr:hlefevre/hrp4_mj_descrition";
          rev = "5f8df7e6eeb5153ee381394312f5700f36bda1e2";
        };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DHONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "HRP-4 simulation robot model mc_mujoco";
    homepage    = "https://gite.lirmm.fr/hlefevre/hrp4_mj_description";
    # license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
