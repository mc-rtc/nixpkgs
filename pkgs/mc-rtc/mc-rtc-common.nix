{
  fetchFromGitHub,
}:

let
  version = "2.14.1";
  # TODO: Release
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_rtc";
    rev = "1c2becf16af82eba6702032367d87cad8d90ecdd";
    hash = "sha256-eNztUtLf7PJylUbPuENyb7Cp8xnu5zerWX4ca1ZgyL8=";
  };
in
{
  inherit version src;
}
