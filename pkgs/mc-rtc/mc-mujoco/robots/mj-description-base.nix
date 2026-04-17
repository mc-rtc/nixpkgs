{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pname,
  owner ? "isri-aist",
  repo,
  description ? null,
  version ? "1.0.0",
  hash ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  version = version;
  pname = pname;

  src = fetchFromGitHub {
    owner = owner;
    repo = repo;
    tag = "v${finalAttrs.version}";
    hash = hash;
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
    description =
      if description != null then description else "${pname} simulation robot model for mc_mujoco";
    homepage = "https://github.com/${owner}/${repo}";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
