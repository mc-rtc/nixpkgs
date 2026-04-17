{
  stdenv,
  lib,
  fetchgit,
  cmake,
  eigen,
  boost,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "gram-savitzky-golay";
  version = "1.0.1";

  src = fetchgit {
    url = "https://github.com/jrl-umi3218/gram_savitzky_golay.git";
    # 1.0.1
    rev = "3f767e3ca366677ed189c33ee14a86cc6e9b34a6";
    hash = "sha256-RC0DmjbB8W0QIHGje907iuiRh0DAF4Skdo4U7qT51Og=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    eigen
    boost
  ];

  cmakeFlags = [ ];

  doCheck = false;

  meta = with lib; {
    description = "C++ Implementation of Savitzky-Golay filtering based on Gram polynomials";
    homepage = "https://github.com/jrl-umi3218/gram_savitzky_golay";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
