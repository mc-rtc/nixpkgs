{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  pepper-description,
}:
stdenv.mkDerivation {
  pname = "mc-pepper";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_pepper";
    rev = "b3e5241c53b7e5541b495884d42fb45f965c82e9";
    hash = "sha256-+etNk725BbzWuOMdfhwkpmsiDPwy7fKOvWfjpHIvre0=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    pepper-description
  ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "pepper robot module for mc_rtc";
    homepage = "https://github.com/jrl-umi3218/mc_pepper";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
