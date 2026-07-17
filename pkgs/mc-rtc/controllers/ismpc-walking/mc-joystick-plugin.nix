{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodulesv2,
  mc-rtc,
}:

stdenv.mkDerivation rec {
  pname = "mc-joystick-plugin";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "mc_joystick_plugin";
    rev = "781db4266daf6346e270115c1908350d25c3ba0e";
    hash = "sha256-YKnvYEeNFYNWdEGVoxhDlYXXCTkn0DlQYzbglB0pJNc=";
  };

  buildInputs = [ jrl-cmakemodulesv2 ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
  ];

  cmakeFlags = [ ];

  doCheck = true;

  meta = with lib; {
    description = "";
    homepage = "https://github.com/isri-aist/mc_joystick_plugin";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
