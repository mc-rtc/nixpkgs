{ stdenv, lib, fetchFromGitHub, cmake, mc-rtc, ur5e-description } :

let

ur5e-description' = ur5e-description.override {
  with-ros = mc-rtc.with-ros;
};

in

stdenv.mkDerivation {
  pname = "mc-ur5e";
  version = "1.0.0";

  src =
    fetchFromGitHub {
      owner = "isri-aist";
      repo = "mc_ur5e";
      rev = "980e2f0914df67653a261d0aaeb6aa50eb483df9";
      hash = "sha256-+E0XzvxJonmjAi08UXwh+tZHEkn0Eik+kPMQcmD30dA=";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ ur5e-description' mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "ur5e RobotModule for mc-rtc";
    homepage    = "https://github.com/isri-aist/mc_ur5e";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
