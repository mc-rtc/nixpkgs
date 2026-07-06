{
  fetchFromGitHub,
}:

let
  version = "2.15-unreleased";
  # TODO: Release
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "44829097027038747ee2be3a223fef1e27936c0b";
    hash = "sha256-Krcey6ubiX0CQKJDLUgZwCCGiTpF6CGqTO9a9lWmTqs=";
  };
in
{
  inherit version src;
}
