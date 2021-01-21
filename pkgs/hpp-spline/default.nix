{ stdenv, fetchurl, cmake, eigen }:

stdenv.mkDerivation {
  pname = "hpp-spline";
  version = "4.8.2";

  src = fetchurl {
    url = "https://github.com/gergondet/hpp-spline/releases/download/v4.8.2-debian.1/hpp-spline-v.4.8.2-debian.1.tar.gz";
    sha256 = "00pnhipcrxr7088081fn2r4kzrzyrk03s7jr1yn89wxwxm1xv2rs";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_PYTHON_INTERFACE=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A template-based library for creating curves of arbitrary order";
    homepage    = "https://github.com/humanoid-path-planner/hpp-spline";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
