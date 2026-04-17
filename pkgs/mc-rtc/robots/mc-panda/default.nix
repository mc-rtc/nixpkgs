{
  stdenv,
  lib,
  fetchgit,
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
    fetchgit {
      url = "https://github.com/arntanguy/mc_panda";
      # topic/nix
      rev = "34933cdd9802493627f4a0470166b87580be43ae";
      sha256 = "sha256-bj/wGDqYwmzMqJ5wziX1x/+gXamYsCXrhB2/anN0Gmk=";
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
