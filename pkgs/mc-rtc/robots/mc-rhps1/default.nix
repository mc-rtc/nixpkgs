{ stdenv, lib, cmake, mc-rtc, rhps1-description } :

let

rhps1-description' = rhps1-description.override {
  with-ros = mc-rtc.with-ros;
};

in

stdenv.mkDerivation (finalAttrs: {
  pname = "mc-rhps1";
  version = "1.0.0";

  src = builtins.fetchGit {
      url = "git@github.com:isri-aist/mc_rhps1";
      rev = "4e53bc180321b29354fbd1b2f0f3d30dea8df282";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ rhps1-description' mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "RHPS1 RobotModule for mc-rtc";
    homepage    = "https://github.com/isri-aist/mc_rhps1";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
