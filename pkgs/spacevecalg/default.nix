{ stdenv, lib, fetchurl, cmake, eigen }:

stdenv.mkDerivation {
  pname = "spacevecalg";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/SpaceVecAlg/releases/download/v1.1.1/SpaceVecAlg-v1.1.1.tar.gz";
    sha256 = "1x11w06czyhpmzl39qm14qxqqipj74rzb2vvdvhs1dnizk54aim9";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Spatial Vector Algebra with the Eigen library";
    homepage    = "https://github.com/jrl-umi3218/SpaceVecAlg";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
