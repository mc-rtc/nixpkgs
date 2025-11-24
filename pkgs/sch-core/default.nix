{
  lib,
  stdenv,
  cmake,
  eigen,
  doxygen,
  boost,
  fetchurl
}:

stdenv.mkDerivation rec {
  pname = "sch-core";
  version = "1.4.3";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/${pname}/releases/download/v${version}/${pname}-v${version}.tar.gz";
    sha256 = "aa10a427bafc3fbe4fc687d1785b079539a438597b7b6ba20ae230d5286074dd";
  };

  nativeBuildInputs = [ cmake doxygen boost ];
  propagatedBuildInputs = [ eigen ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "sch-core: Effective proximity queries";
    homepage    = "https://github.com/jrl-umi3218/sch-core";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
