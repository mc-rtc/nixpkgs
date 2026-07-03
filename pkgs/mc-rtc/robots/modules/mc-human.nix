{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  human-description,
}:
stdenv.mkDerivation {
  pname = "mc-human";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_human";
    rev = "30854430e0956c075b0553c3c7dce6d8e4894e43";
    hash = "sha256-xD8KtlyJIlarlipCupaTcY5eADHvFhJXwDRsqPQeG6Q=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    human-description
  ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Human robot module for mc_rtc";
    homepage = "https://github.com/jrl-umi3218/mc_human";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
