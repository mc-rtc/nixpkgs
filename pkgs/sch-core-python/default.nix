{
  lib,
  stdenv,
  cmake,
  sch-core,
  spacevecalg,
  python3Packages,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "sch-core-python";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "sch-core-python";
    rev = "9b4a7d8189de30dc49edc7ccb0e1283e85686e62";
    hash = "sha256-Ml0fATe61R7tJ5m20Y7hjDwCa/WwIIG3f+qwV1zSz8k=";
  };

  nativeBuildInputs = [
    cmake
    python3Packages.cython
    python3Packages.python
    python3Packages.distutils
    python3Packages.pytest
  ];
  propagatedBuildInputs = [
    sch-core
    spacevecalg
    python3Packages.spacevecalg
  ];

  cmakeFlags = [
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  # Override the default CMake install step
  installPhase = ''
    runHook preInstall

    # 1. Define the destination directory inside the Nix store output
    # Using python.sitePackages handles the "lib/python3.13/site-packages" string automatically
    local targetDir="$out/${python3Packages.python.sitePackages}/sch"
    mkdir -p "$targetDir"

    ls -lR

    # 2. Copy your built files from the build tree to the target store path
    # (Adjust 'build/python/Release/eigen/' path if your build folder structure differs slightly)
    cp -r python/Release/sch/* "$targetDir"

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "sch-core: python bindings for sch-core - effective proximity queries";
    homepage = "https://github.com/jrl-umi3218/sch-core-python";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
