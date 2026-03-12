{ stdenv, lib, fetchFromGitHub,
cmake, mc-rtc,
socat, picocom, screen, minicom,
useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mc-force-shoe-plugin";
  version = "2.0.0";

  src = if useLocal then
      builtins.trace "Using local workspace for mc-force-shoe-plugin: ${localWorkspace}/mc_force_shoe_plugin"
      (builtins.path {
        path = "${localWorkspace}/mc_force_shoe_plugin";
        name = "mc-force-shoe-plugin-src";
      })
    else
      fetchFromGitHub {
        owner = "Hugo-L3174";
        repo = "mc_force_shoe_plugin";
        tag = "v${finalAttrs.version}";
        hash = "sha256-mgtuJ0rmFKSgtth+/uVnvIJvXY7Ij8veywQ7Fm1neyk=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs =
    [
      mc-rtc
      socat picocom screen minicom # make serial communication debugging tools available
    ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule for mc-rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_panda";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
})
