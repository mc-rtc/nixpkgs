{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  # TODO: Release
  # src = fetchFromGitHub {
  #   owner = "jrl-umi3218";
  #   repo = "mc_rtc";
  #   rev = "cb1850732afa034ef99e42c6e1158a1a0f3bbb0c";
  #   hash = "sha256-rmIRRFqiToZTdGPt24VYYGk+UsdkRRrixR4F3heeH0s=";
  # };
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "70e8a93d6657dc5bc46aff6f7271d8953e4a2b22";
    hash = "sha256-TuyiflhG44zsABmewrpihGv1sM8vs/GECf84l6N41jE=";
  };
in
{
  inherit version src;
}
