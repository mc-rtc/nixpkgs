{
  fetchFromGitHub,
}:

let
  version = "2.16.0";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    tag = "v2.16.0";
    hash = "sha256-/2wPV6jnn94shUUFpIiDv6cazA0duPSF3WKduzEU39E=";
  };
in
{
  inherit version src;
}
