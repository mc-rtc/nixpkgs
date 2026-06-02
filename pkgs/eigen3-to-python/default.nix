{
  stdenv,
  lib,
  cmake,
  pkg-config,
  eigen,
  fetchFromGitHub,
  python3Packages,
}:

stdenv.mkDerivation {
  pname = "eigen3-to-python";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "Eigen3ToPython";
    tag = "v1.0.7";
    hash = "sha256-T5fhNj5AjFS/F+Q+aCHfL0fW9uMQoGEhYLf5u2aPrQk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python3Packages.cython
    python3Packages.python
    python3Packages.distutils
    python3Packages.pytest
    python3Packages.pip
  ];

  propagatedBuildInputs = [
    eigen
    python3Packages.numpy
  ];

  cmakeFlags = [
    "-DPIP_INSTALL_PREFIX=$out/lib/python3"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCYTHON_USE_CACHE=OFF"
  ];

  # Force pip to ignore the EXTERNALLY-MANAGED restriction in the sandbox
  PIP_BREAK_SYSTEM_PACKAGES = 1;
  # Force pip to use the Nix-provided python packages instead of checking PyPI
  PIP_NO_BUILD_ISOLATION = 1;

  # Force Cython/Python to use the build directory for caching instead of /homeless-shelter
  preBuild = ''
    export HOME=$TMPDIR
  '';

  doCheck = true;

  # Override the default CMake install step
  installPhase = ''
    runHook preInstall

    # 1. Define the destination directory inside the Nix store output
    # Using python.sitePackages handles the "lib/python3.13/site-packages" string automatically
    local targetDir="$out/${python3Packages.python.sitePackages}/eigen"
    mkdir -p "$targetDir"

    # 2. Copy your built files from the build tree to the target store path
    # (Adjust 'build/python/Release/eigen/' path if your build folder structure differs slightly)
    cp -r python/Release/eigen/* "$targetDir"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Provide Eigen3 to numpy conversion";
    homepage = "https://github.com/jrl-umi3218/Eigen3ToPython";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
