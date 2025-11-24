{ stdenv, lib, fetchurl, fetchFromGitHub, cmake, with-ros ? false, colcon, buildRosPackage }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) rec {
  pname = "mc-rtc-data";
  version = "1.0.8";


  # TODO: remove ROSFree branch
  src = if with-ros then
      fetchurl {
        url = "https://github.com/jrl-umi3218/mc_rtc_data/releases/download/v${version}/mc_rtc_data-v${version}.tar.gz";
        sha256 = "0gvznx4ivcv6ajp6d3j8p942n0spmnzza1lzgib6h1lpi3zhnb38";
      }
    else
      fetchFromGitHub { # ROSFree branch
        owner = "jrl-umi3218";
        repo = "mc_rtc_data";
        rev = "ca84a40a0a27783c4ed63bd8f057af7ef41b33bb";
        sha256 = "sha256-ntz/u9YTWd2YuVhtRngm0qnOU8nsH0ODZ828x/Uba9s=";
        fetchSubmodules = true;
      };

  nativeBuildInputs = if with-ros then [ colcon ] else [ cmake ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Data for mc_rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc_data";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
