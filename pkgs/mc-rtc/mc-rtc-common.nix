{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "c193a3d46c6e8f9bbf5275e612f6ddf3f53ca6b2";
    hash = "sha256-jrQc7LLAvb0BD8eTSdeqUKayz8yOru6wno3s7/sLQA4=";
  };
in
{
  inherit version src;
}
