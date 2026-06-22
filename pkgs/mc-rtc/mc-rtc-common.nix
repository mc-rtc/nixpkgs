{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  # TODO: Release
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "c09df00517a18f53236ce4b66599e9e6b68e3c08";
    hash = "sha256-HpgoiO8cvYeocr+t7eYN3imb7Oi5C+EYlEZ0GQzu4IA=";
  };
in
{
  inherit version src;
}
