{ stdenv, fetchurl, cmake, boost }:

stdenv.mkDerivation {
  pname = "sch-core";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/sch-core/releases/download/v1.1.0/sch-core-v1.1.0.tar.gz";
    sha256 = "1p5552m3k4wbjcsrcpxdkcvifii7118vyhwf8j90q6hlg0310fk6";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "sch-core: Effective proximity queries";
    homepage    = "https://github.com/jrl-umi3218/sch-core";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
