{ stdenv, lib, fetchFromGitHub, cmake, mc-rtc, g1-description } :

let

g1-description' = g1-description.override {
  with-ros = mc-rtc.with-ros;
};

in

stdenv.mkDerivation {
  pname = "mc-g1";
  version = "1.0.0";

  src = 
    fetchFromGitHub {
      owner = "isri-aist";
      repo = "mc_g1";
      rev = "d30edab21f5ec00ef737e55d56ba5e2afc89460e";
      hash = "sha256-Ispz48omVbcgCpCHwZ3XhUF0UcCc2hQllprGGB0O01Y=";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ g1-description' mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "g1 RobotModule for mc-rtc";
    homepage    = "https://github.com/isri-aist/mc_g1";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
