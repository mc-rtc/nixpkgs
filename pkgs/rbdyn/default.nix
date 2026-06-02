{
  stdenv,
  lib,
  cmake,
  spacevecalg,
  yaml-cpp,
  tinyxml-2,
  boost,
  fetchurl,
  python3Packages,
}:

stdenv.mkDerivation rec {
  pname = "rbyn";
  version = "1.9.2";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/RBDyn/releases/download/v${version}/RBDyn-v${version}.tar.gz";
    sha256 = "sha256-IFqX4z8r2JTwgNnPB35/vZKwgWoPO78ebnUvPdNOnjY=";
  };

  nativeBuildInputs = [
    cmake
    python3Packages.cython
    python3Packages.python
    python3Packages.distutils
    python3Packages.pytest
  ];

  propagatedBuildInputs = [
    spacevecalg
    yaml-cpp
    tinyxml-2
    boost
    python3Packages.spacevecalg
  ]; # Add other dependencies here

  # XXX: Without this fixupPhase fails due to RPATHS references to /build/
  preFixup = ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/${python3Packages.python.sitePackages}/rbdyn/rbdyn.so
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/${python3Packages.python.sitePackages}/rbdyn/parsers/parsers.so
  '';

  doCheck = true;

  meta = with lib; {
    description = "Model the dynamics of rigid body systems";
    homepage = "https://github.com/jrl-umi3218/RBDyn";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
