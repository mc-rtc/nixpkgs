{ stdenv, lib, cmake, spacevecalg, yaml-cpp, tinyxml-2, boost, fetchurl }:

stdenv.mkDerivation rec {
  pname = "rbyn";
  version = "1.9.2";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/RBDyn/releases/download/v${version}/RBDyn-v${version}.tar.gz";
    sha256 = "sha256-IFqX4z8r2JTwgNnPB35/vZKwgWoPO78ebnUvPdNOnjY=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ spacevecalg yaml-cpp tinyxml-2 boost ]; # Add other dependencies here

  postPatch = ''
    # Remove the include from the main CMakeLists.txt
    sed -i '/include(cmake\/cython\/cython.cmake)/d' CMakeLists.txt

    # Add the include to the top of the python binding CMakeLists.txt
    sed -i '1i include(cmake/cython/cython.cmake)' binding/python/CMakeLists.txt
  '';

  doCheck = true;

  meta = with lib; {
    description = "Model the dynamics of rigid body systems";
    homepage    = "https://github.com/jrl-umi3218/RBDyn";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
