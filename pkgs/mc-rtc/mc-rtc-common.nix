{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  # TODO: PR 538
  src = fetchFromGitHub {
    owner = "Kooolkimooov";
    repo = "mc_rtc";
    rev = "2846f365824531f162635323d0c32796842e02a8";
    hash = "sha256-zTxxZOZCwlMGrRGG8B9kRLJcCvXLvYSigej8yDpihwg=";
  };
in
{
  inherit version src;
}
