{
  stdenv,
  lib,
  fetchgit,
  cmake,
  mc-rtc,
}:

stdenv.mkDerivation {
  pname = "mc-udp";
  version = "1.0.0";

  # master branch as of 2025.24.13
  # TODO: do a proper 1.0.0 release
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/mc_udp";
    rev = "b6be9c9423b6c68a3b375641e99affed448cf825";
    sha256 = "";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DBUILD_OPENRTM_SERVER=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "UDP interface for mc_rtc";
    homepage = "https://github.com/jrl-umi3218/mc_udp";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
