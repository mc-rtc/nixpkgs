{
  stdenv,
  lib,
  cmake,
  mc-rtc,
  hrp4-description,
  useLocal ? false,
  localWorkspace ? null,
}:

let

  hrp4-description' = hrp4-description.override {
    with-ros = mc-rtc.with-ros;
  };

in

stdenv.mkDerivation {
  pname = "mc-hrp4";
  version = "1.0.0";

  src =
    if useLocal then
      builtins.trace "Using local workspace for mc-hrp4: ${localWorkspace}/mc-hrp4" (
        builtins.path {
          path = "${localWorkspace}/mc-hrp4";
          name = "mc-hrp4-src";
        }
      )
    else
      builtins.fetchGit {
        url = "git@github.com:isri-aist/mc-hrp4";
        # Release v1.0.0
        rev = "52f03f0f06392eee669d84a995c2f4b797246bd7";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hrp4-description'
    mc-rtc
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP4 RobotModule for mc-rtc";
    homepage = "https://gite.lirmm.fr/mc-hrp4/mc-hrp4";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
