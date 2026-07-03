{
  stdenv,
  lib,
  cmake,
  mc-rtc,
  miroki-description,
}:
stdenv.mkDerivation {
  pname = "mc-miroki";
  version = "0.0.0";

  src = fetchGit {
    url = "git@github.com:isri-aist/mc_miroki";
    rev = "f783343513a9beab86c33ce286e49f7291ed963e";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    miroki-description
  ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Miroki robot module for mc_rtc";
    homepage = "https://github.com/isri-aist/mc_miroki";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
