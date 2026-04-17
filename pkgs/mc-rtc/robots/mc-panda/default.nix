{
  stdenv,
  lib,
  fetchgit,
  cmake,
  mc-rtc,
  libfranka, # use jrl-umi3218 fork
}:

stdenv.mkDerivation {
  pname = "mc-panda";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/arntanguy/mc_panda";
    # topic/nix
    rev = "34933cdd9802493627f4a0470166b87580be43ae";
    sha256 = "sha256-bj/wGDqYwmzMqJ5wziX1x/+gXamYsCXrhB2/anN0Gmk=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    libfranka
  ];

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
