{
  fetchFromGitHub,
}:

let
  version = "2.15.0";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    tag = "v2.15.0";
    hash = "sha256-YwE3HGdjX8scGIrS7F/zOy0KaNLQB9M1ANpwgNZNjS8=";
  };
in
{
  inherit version src;
}
