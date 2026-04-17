{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "mc-robot-model-update";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_robot_model_update";
    # tag = "v${finalAttrs.version}";
    # future v2.0.0 version once https://github.com/jrl-umi3218/mc_robot_model_update/pull/2 is merged
    rev = "e6e2aa61459020729891e93817c83e8199697b08";
    hash = "sha256-/gvwqy73elA6gUppwd7OSp0jkojHZUDZGUJlAVnkodU=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
  ];

  cmakeFlags = [
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Plugin to update some parameters of a robot model live or from configuration ";
    homepage = "https://github.com/jrl-umi3218/mc_robot_model_update";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
})
