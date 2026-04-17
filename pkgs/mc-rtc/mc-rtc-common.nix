{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "d09e062acd60bb07c8e76b74a50f460ba2a2e6ed";
    hash = "sha256-W4Mx8DCYdEvaTFoXxkaT+9WKwd4be8tX8FJY7Gtfn84=";
  };
in
{
  inherit version src;
}
