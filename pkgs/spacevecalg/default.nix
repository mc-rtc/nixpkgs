{
  stdenv,
  lib,
  cmake,
  jrl-cmakemodules,
  doxygen,
  eigen,
  boost,
  fetchFromGitHub,
  python3Packages,
  graphviz,
  sphinx,
  sphinx-cmake,
}:

stdenv.mkDerivation {
  pname = "spacevecalg";
  version = "1.2.10";
  dontWrapQtApps = true; # XXX: why is this needed?
  # pull 74
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "spacevecalg";
    rev = "6d720a1c14168759874c9016a6bda7125d956c9e";
    hash = "sha256-6zMUa6iuDgEV4ArzfvKtP3dZ82niBOzXfmvtUTyFoN4=";
  };
  outputs = [
    "out"
    "doc"
  ];
  cmakeFlags = [
    (lib.cmakeBool "PYTHON_BINDINGS" false)
    (lib.cmakeBool "BUILD_DOCUMENTATION" true)
    (lib.cmakeBool "INSTALL_DOCUMENTATION" true)
    (lib.cmakeBool "NANOBIND_BINDINGS" true)
    (lib.cmakeBool "NANOBIND_DOCUMENTATION" true)
    (lib.cmakeBool "BUILD_TESTING" false)
  ];
  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
    doxygen
    python3Packages.python
    python3Packages.pythonImportsCheckHook
    python3Packages.pytestCheckHook
    # nanobind documentation
    graphviz
    sphinx
    sphinx-cmake
    python3Packages.sphinx-autodoc2
    python3Packages.sphinx-book-theme
  ];
  propagatedBuildInputs = [
    eigen
    boost
    python3Packages.nanoeigenpy
    python3Packages.nanobind
  ];

  # pytest
  pythonImportsCheck = [ "sva" ];
  pytestFlagsArray = [ "$src/binding/nanobind/tests" ];
}
