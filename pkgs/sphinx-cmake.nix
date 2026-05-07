{
  stdenv,
  fetchFromGitHub,
  cmake,
  sphinx,
}:

stdenv.mkDerivation {
  pname = "sphinx-cmake";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "python-cmake";
    repo = "sphinx-cmake";
    rev = "7a390a2b17b605978e5cc1358692e22c32acffb0";
    hash = "sha256-Z2PRdOB5MpBnjvnrQ6MOAPofteOu/blceAWVTtqqTeQ=";
  };

  # We don't need to build anything, just install the file
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ (builtins.trace "sphinx out: ${sphinx}" sphinx) ];

  installPhase = ''
    mkdir -p $out/lib/cmake/sphinx-cmake
    cp cmake/FindSphinx.cmake $out/lib/cmake/sphinx-cmake/
  '';

  postFixup = ''
      mkdir -p $out/nix-support
      cat > $out/nix-support/setup-hook <<EOF
      add_sphinx_to_cmake_flags() {
        # This appends the module path to the actual flags passed to the cmake command
        export cmakeFlags="\$cmakeFlags -DCMAKE_MODULE_PATH=$out/lib/cmake/sphinx-cmake"
      }
      addEnvHooks "\$hostOffset" add_sphinx_to_cmake_flags
    EOF
  '';
}
