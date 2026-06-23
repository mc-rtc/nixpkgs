{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  libfranka,
  mc-panda,
  with-rt ? true,
  sudo ? null,
  libcap ? null,
}:

let
  use-rt =
    if (with-rt && stdenv.hostPlatform.isDarwin) then
      builtins.trace "mc-franka: disabling with-rt option because it is currently not supported on darwin" false
    else
      with-rt;
in
stdenv.mkDerivation {
  pname = "mc-franka";
  version = "1.0.0";

  # TODO: release mc-franka
  # topic/nix
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_franka";
    rev = "28f38fa3c3ca0fc6d3c42ee552e2ca26bec38bf9";
    hash = "sha256-H1J2Z74xxh2shfwlNWLxXoTWxgeUE1SErQW8WtNnCng=";
  };

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals (use-rt && !stdenv.hostPlatform.isDarwin) [
    sudo
    libcap
  ];
  propagatedBuildInputs = [
    mc-rtc
    libfranka
    mc-panda
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_REALTIME" use-rt)
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
