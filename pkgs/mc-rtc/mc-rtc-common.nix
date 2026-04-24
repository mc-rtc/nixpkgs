{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "d1bb28f9bfab85a04ce1ff103289676cfa5bf4fc";
    hash = "sha256-a8Wh5Xhvs+vM7k0uEJzSDCSUOK58AJSRSJx3XyboHO0=";
  };
in
{
  inherit version src;
}
