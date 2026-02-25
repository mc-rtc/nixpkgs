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
        rev = "813c3dfc9294dc448fe6157e9a1483e14eaf6c7c";
        sha256 = "sha256-SDePGlOb/zHKu3ejOYWJoIpj+2b9g9D36Kri3UlCBdk=";
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
