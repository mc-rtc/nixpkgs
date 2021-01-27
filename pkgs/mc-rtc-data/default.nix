{ stdenv, fetchurl, cmake, with-ros ? false, catkin, buildRosPackage }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "mc-rtc-data";
  version = "1.0.4";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/mc_rtc_data/releases/download/v1.0.4/mc_rtc_data-v1.0.4.tar.gz";
    sha256 = "0gvznx4ivcv6ajp6d3j8p942n0spmnzza1lzgib6h1lpi3zhnb38";
  };

  nativeBuildInputs = if with-ros then [ catkin ] else [ cmake ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Data for mc_rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc_data";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
