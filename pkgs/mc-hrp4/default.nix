{ stdenv, fetchgit, cmake, mc-rtc, hrp4-description } :

let

hrp4-description' = hrp4-description.override {
  with-ros = mc-rtc.with-ros;
};

in

stdenv.mkDerivation {
  pname = "mc-hrp4";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@gite.lirmm.fr:mc-hrp4/mc-hrp4";
    rev = "dc6f164767fc9cfc9023e7b006784080114cb7f3";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ hrp4-description' mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "HRP4 RobotModule for mc-rtc";
    homepage    = "https://gite.lirmm.fr/mc-hrp4/mc-hrp4";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
