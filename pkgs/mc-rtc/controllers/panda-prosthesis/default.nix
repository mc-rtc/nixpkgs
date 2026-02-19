{ stdenv, lib, fetchgit, 
cmake, mc-rtc,
mc-panda-lirmm,
useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation {
  pname = "panda-prosthesis";
  version = "1.0.0";

  src = if useLocal then
      builtins.trace "Using local workspace for panda-prosthesis: ${localWorkspace}/panda_prosthesis_rolkneematics"
      (builtins.path {
        path = "${localWorkspace}/panda_prosthesis_rolkneematics";
        name = "panda-prosthesis-src";
      })
    else
      # TODO: release panda-prosthesis
      fetchgit {
        #url = "https://github.com/ROLKNEEMATICS/panda_prosthesis";
        url = "https://github.com/arntanguy/panda_prosthesis_rolkneematics";
        rev = "24e3a3b35e1b3266e8bac6128d216c4665ef65b5";
        sha256 = "sha256-XdRmfMZPMFMqdNCRc7VBjQQAh5t5g00GxI3T+pN5F4E=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs =
    [ mc-rtc mc-panda-lirmm ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule for mc-rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_panda";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
