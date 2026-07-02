{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  libfranka_0_9_2,
  franka-description,
  xacro,
  with-ros ? false,
}:

stdenv.mkDerivation {
  pname = "mc-panda";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_panda";
    tag = "v2.0.0";
    hash = "sha256-CUFxcBXTsDplywrDNGyHB3ZkBIirNWeViY494h3Hxbk=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = builtins.trace "panda with-ros: ${toString with-ros}" (
    [
      mc-rtc
      libfranka_0_9_2
    ]
    ++ lib.optional (with-ros) [
      franka-description
      xacro
    ]
  );

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule for mc-rtc";
    homepage = "https://github.com/jrl-umi3218/mc_panda";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
