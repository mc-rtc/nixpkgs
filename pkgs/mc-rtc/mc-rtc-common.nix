{
  fetchFromGitHub,
}:

let
  version = "2.16.0";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "4698b2270b1cbf6ce01943d494279ac52452b26a";
    hash = "sha256-TPZp6wP4oQC/BdMxM1UVJxyDG2ihu3YTZu8pNU+z72o=";
  };
in
{
  inherit version src;
}
