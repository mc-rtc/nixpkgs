{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (_finalAttrs: {
  version = "0.0.0";
  pname = "human_mj_description";

  src = fetchFromGitHub {
    owner = "Hugo-L3174";
    repo = "human_mj_description";
    rev = "e0cfab7e09e4b6f8dc131a1769cbc968fffbb99e";
    hash = "sha256-bz2i8lJMoDTHUcoRL5bM47f8X0jt84IvFn9CIHv/lzk=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DHONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Human simulation robot model mc_mujoco";
    homepage = "https://github.com/Hugo-L3174/human_mj_description";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
