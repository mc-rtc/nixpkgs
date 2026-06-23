{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  libfranka_0_9_2,
  mc-panda,
  with-rt ? false,
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
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_franka";
    rev = "1d2e73df4c830ea950d15afaba659c8f470435e1";
    hash = "sha256-N4pUjpGqoMuzllfZF5B0Sva+sP71LszY/AXarEO9mAw=";
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
    libfranka_0_9_2
    mc-panda
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_REALTIME" use-rt)
    "-DPYTHON_BINDING=OFF"
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
