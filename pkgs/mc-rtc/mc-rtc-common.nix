{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  # TODO: Release
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "cb1850732afa034ef99e42c6e1158a1a0f3bbb0c";
    hash = "sha256-rmIRRFqiToZTdGPt24VYYGk+UsdkRRrixR4F3heeH0s=";
  };
in
{
  inherit version src;
}
