{ stdenv, lib, fetchgit, 
cmake, mc-rtc, libfranka, mc-panda,
sudo, libcap,
useLocal ? false, localWorkspace ? null,
} :

stdenv.mkDerivation {
  pname = "mc-franka";
  version = "1.0.0";

  src = if useLocal then
      builtins.trace "Using local workspace for mc-franka: ${localWorkspace}/mc_franka"
      (builtins.path {
        path = "${localWorkspace}/mc_franka";
        name = "mc-franka-src";
      })
    else
      # TODO: release mc-franka
      fetchgit {
        url = "https://github.com/arntanguy/mc_franka";
        # topic/nix
        rev = "f5fca4b2ac4bd1076a2b02243cac18eb71f87627";
        sha256 = "sha256-kWmK06gXrFcUpQTPArlVxPlWSl/q/z4VgawV+NDjtyY=";
      };

  nativeBuildInputs = [ cmake sudo libcap ];
  propagatedBuildInputs = [ mc-rtc libfranka mc-panda ];

  cmakeFlags = [
    "-DUSE_REALTIME=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Interface between libfranka and mc_rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_franka";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
