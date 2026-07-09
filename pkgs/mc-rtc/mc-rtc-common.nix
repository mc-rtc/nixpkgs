{
  fetchFromGitHub,
}:

let
  version = "2.15.0";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    tag = "v2.15.0";
    hash = "sha256-uA/VtebPG+ljTNpeDY2MUnOEAB3SaHrKE0XnlmaGkTo=";
  };
in
{
  inherit version src;
}
