{
  fetchFromGitHub,
}:

let
  version = "2.17.1";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    tag = "v2.17.1";
    hash = "sha256-wE0dtDrj3dSrn3uZ64Y0PKo6/c1M47x/qyl0BPTz2Co=";
  };
in
{
  inherit version src;
}
