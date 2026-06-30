{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
}:

stdenv.mkDerivation {
  pname = "robogami-controller";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "anastasiabolotnikova";
    repo = "robogami_controller";
    rev = "5af1598e3c71957c08d979bb4f5e004a3fb878a1";
    hash = "sha256-Ji7tcsKXW3XVisMg/I8HpVFFSg39e/KPBztNqrNTix8=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Single Robogami module mc_rtc FSM controller";
    homepage = "https://github.com/anastasiabolotnikova/robogami_controller";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
