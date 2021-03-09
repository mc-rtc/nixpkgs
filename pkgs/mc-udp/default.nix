{ stdenv, lib, fetchgit, cmake, mc-rtc }:

stdenv.mkDerivation {
  pname = "mc-udp";
  version = "1.0.0";

  # master branch as of 2021.01.28
  src = if mc-rtc.with-tvm then
    fetchgit {
      url = "https://github.com/gergondet/mc_udp";
      rev = "5c15b7013353d9d86926dcc258efccbdefa1366d";
      sha256 = "047q4aw0sgafh7si2bqxl70wanr6kf07ykf4x9dd643d0qimcsrs";
    }
  else
    fetchgit {
      url = "https://github.com/jrl-umi3218/mc_udp";
      rev = "80e4b55811f2dc5d10f2883ed190fc4ade22bf60";
      sha256 = "1xz5v579lx9srwl26362fp9lgbhw0z09pj740bq3k0ra4226wksn";
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
    homepage    = "https://github.com/jrl-umi3218/mc_udp";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
