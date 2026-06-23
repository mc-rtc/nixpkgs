{
  stdenv,
  lib,
  fetchFromGitHub,
  mc-panda,
  cmake,
}:

let
  version = "1.0.0";
in
stdenv.mkDerivation {
  pname = "mc-panda-lirmm";
  version = "${version}";

  src =
    # TODO: release mc-panda-lirmm
    fetchFromGitHub {
      owner = "jrl-umi3218";
      repo = "mc_panda_lirmm";
      rev = "abe9116f7fe216e30577203b6e03f44f2e3e6b58";
      hash = "sha256-LFxQgzjKPFuZjVkVIZPw5IXtS9rpSrQqPVcbQGUkHVU=";
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
