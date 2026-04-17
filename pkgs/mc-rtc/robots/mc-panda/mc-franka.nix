{
  stdenv,
  lib,
  fetchgit,
  cmake,
  mc-rtc,
  libfranka,
  mc-panda,
  sudo,
  libcap,
}:

stdenv.mkDerivation {
  pname = "mc-franka";
  version = "1.0.0";

  src =
    # TODO: release mc-franka
    fetchgit {
      url = "https://github.com/jrl-umi3218/mc_franka";
      # topic/nix
      rev = "a1ee4100b489d50f1c9cbe7e5913183939678ef3";
      sha256 = "sha256-CXh2wCVIC3FxZ+bBmHXNGXYGqiqFStITFj9NRgGT5EU=";
    };

  nativeBuildInputs = [
    cmake
    sudo
    libcap
  ];
  propagatedBuildInputs = [
    mc-rtc
    libfranka
    mc-panda
  ];

  cmakeFlags = [
    "-DUSE_REALTIME=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Interface between libfranka and mc_rtc";
    homepage = "https://github.com/jrl-umi3218/mc_franka";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
