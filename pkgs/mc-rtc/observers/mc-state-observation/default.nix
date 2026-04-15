{
  stdenv,
  lib,
  fetchurl,
  cmake,
  mc-rtc,
  useLocal ? false,
  localWorkspace ? null,
  with-ros ? false,
}:

stdenv.mkDerivation rec {
  pname = "mc-state-observation";
  version = "1.1.0";

  src =
    if useLocal then
      builtins.trace "Using local workspace for ${pname}: ${localWorkspace}/mc_state_obeservation" (
        builtins.path {
          path = "${localWorkspace}/mc_state_observation";
          name = "mc_state_observation-src";
        }
      )
    else
      fetchurl {
        url = "https://github.com/jrl-umi3218/mc_state_observation/releases/download/v${version}/mc_state_observation-v${version}.tar.gz";
        sha256 = "sha256-F1LzhAK0MQM4mc5+dr0lK364J7f0nA1ZBe1RZlG3Pmo=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-rtc ];

  # This requirement implies < 2.0 but in fact it's fine for this one
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'mc_rtc 1.6 REQUIRED' 'mc_rtc REQUIRED'
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    # XXX: this installs mc-state-observation under its own install prefix because builds in nix are sandboxed
    # so we cannot install to mc_rtc's install prefix directly.
    # Nix will merge all install prefixes into a single one in the final store path for mc-rtc.
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ]
  ++ [ (if with-ros then "-DWITH_ROS_OBSERVERS=ON" else "-DWITH_ROS_OBSERVERS=OFF") ];

  doCheck = false;

  meta = with lib; {
    description = "Extra mc_rtc observers";
    homepage = "https://github.com/jrl-umi3218/mc_state_observation";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
