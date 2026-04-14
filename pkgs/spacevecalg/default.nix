{ stdenv, lib, cmake, jrl-cmakemodules, eigen, boost, fetchurl }:

stdenv.mkDerivation rec {
  pname = "spacevecalg";
  version = "1.2.8";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/SpaceVecAlg/releases/download/v${version}/SpaceVecAlg-v${version}.tar.gz";
    sha256 = "b3ea28efb99cb9197e56bb49bf5c4a40006b0f03e8fbf4f22ad4969573be1c0d";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen boost jrl-cmakemodules ];

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
