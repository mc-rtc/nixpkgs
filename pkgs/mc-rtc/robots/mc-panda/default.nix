{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  libfranka,
  franka-description,
  xacro,
  with-ros ? false,
}:

stdenv.mkDerivation {
  pname = "mc-panda";
  version = "1.0.0";

  src =
    # TODO: release mc-panda
    fetchFromGitHub {
      owner = "jrl-umi3218";
      repo = "mc_panda";
      rev = "f88687e4725a75cdca5e415cc155fc570fb50629";
      hash = "sha256-K8ENsehcDvEbceuWvsvJzdEi5DLJELVpj4KFgjFkpzA=";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = builtins.trace "panda with-ros: ${toString with-ros}" (
    [
      mc-rtc
      libfranka
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
