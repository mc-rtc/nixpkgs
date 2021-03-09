{ stdenv, lib, fetchgit, cmake, mc-rtc, hrp2-description } :

let

hrp2-description' = hrp2-description.override {
  with-ros = mc-rtc.with-ros;
};

in

stdenv.mkDerivation {
  pname = "mc-hrp2";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@gite.lirmm.fr:mc-hrp2/mc-hrp2";
    rev = "da1a1b3c0edbfb235bbc52cceb629a679cca999c";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ hrp2-description' mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP2DRC RobotModule for mc-rtc";
    homepage    = "https://gite.lirmm.fr/mc-hrp2/mc-hrp2";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
