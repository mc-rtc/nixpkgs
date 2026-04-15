{
  stdenv,
  lib,
  fetchgit,
  mc-panda,
  cmake,
  useLocal ? false,
  localWorkspace ? null,
}:

let
  version = "1.0.0";
  localFolder = "mc_panda_lirmm";
in
stdenv.mkDerivation {
  pname = "mc-panda-lirmm";
  version = "${version}";

  src =
    if useLocal then
      builtins.trace "Using local workspace for mc-panda: ${localWorkspace}/${localFolder}" (
        builtins.path {
          path = "${localWorkspace}/${localFolder}";
          name = "mc-panda-lirmm-src";
        }
      )
    else
      # TODO: release mc-panda-lirmm
      fetchgit {
        url = "https://github.com/arntanguy/mc_panda_lirmm";
        # topic/ConnectModules
        rev = "bbc682cd18f01ee6a058971268f8d5b46bffa84f";
        sha256 = "sha256-lEt27kzOaeN2gMFz2p2f2v7Kq97RW/JG12YbinTr2IE=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-panda ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule specialization for LIRMM robots for mc-rtc";
    homepage = "https://github.com/jrl-umi3218/mc_panda_lirmm";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
