{ stdenv, lib, fetchgit, 
cmake, mc-rtc, libfranka, franka-description, xacro, 
useLocal ? false, localWorkspace ? null,
with-ros ? false } :

stdenv.mkDerivation {
  pname = "mc-panda";
  version = "1.0.0";

  src = if useLocal then
      builtins.trace "Using local workspace for mc-panda: ${localWorkspace}/mc_panda"
      (builtins.path {
        path = "${localWorkspace}/mc_panda";
        name = "mc-panda-src";
      })
    else
      # TODO: release mc-panda
      fetchgit {
        url = "https://github.com/arntanguy/mc_panda";
        # topic/nix
        rev = "0718841a4c0dced881a191082cd79afdff248173";
        sha256 = "sha256-Nx/5tsnfqIOGh3iW9bPcQs03PLWm8JXZFPXrjNY7DCA=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs =
    [ mc-rtc libfranka ]
    ++ lib.optional (with-ros) [franka-description xacro];

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
