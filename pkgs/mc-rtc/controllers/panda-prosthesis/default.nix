{ stdenv, lib, fetchFromGitHub, fetchgit, 
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
      # fetchgit {
      #   #url = "https://github.com/ROLKNEEMATICS/panda_prosthesis";
      #   url = "https://github.com/arntanguy/panda_prosthesis_rolkneematics";
      #   # topic/ConnectModules
      #   rev = "edef20d6a4b05ba5868e399d63984f18da64bac4";
      #   sha256 = "sha256-yzIjxDpD0ry6j9+a5n6y+PAgYmtrtwUeZDFC0/M7aR4=";
      # };
      fetchFromGitHub {
        owner = "arntanguy";
        repo = "panda_prosthesis_rolkneematics";
        rev = "topic/ConnectModules";
        hash = "sha256-VgaE9pYQ5J9F9DehK6y7EOGSzsZtgHdspUxKohmMw7E=";
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
