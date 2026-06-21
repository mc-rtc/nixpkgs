{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  spacevecalg,
  yaml-cpp,
  tinyxml-2,
  boost,
  fetchFromGitHub,
  python3Packages,
  with-python ? true,
}:

let
  use-python = with-python && !stdenv.hostPlatform.isDarwin;
in
stdenv.mkDerivation {
  pname = "rbyn";
  version = "1.9.5";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "RBDyn";
    tag = "v1.9.5";
    hash = "sha256-ihQc5+TLL0g7vXdC+yO8Iea0h9inJEIm/Ei1oPV7WpA=";
  };

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
  ]
  ++ lib.optionals use-python [
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
  ]
  ++ lib.optionals use-python [
    python3Packages.spacevecalg
  ];

  cmakeFlags = [
    (lib.cmakeBool "PYTHON_BINDING" use-python)
  ];

  # XXX: Without this fixupPhase fails due to RPATHS references to /build/
  preFixup = lib.optionalString use-python ''
    echo "Running Linux postFixup..."
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
