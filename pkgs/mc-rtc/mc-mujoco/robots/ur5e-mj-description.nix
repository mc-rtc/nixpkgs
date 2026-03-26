{ stdenv, lib, fetchFromGitHub, cmake
, useLocal ? false, localWorkspace ? null
}:

import ./mj-description-base.nix {
  inherit stdenv lib fetchFromGitHub cmake useLocal localWorkspace;
  pname = "ur5e-mj-description";
  repo = "ur5e_mj_description";
  version = "1.0.0";
  hash = "sha256-HYz9fESWwenMopBHyZIbZWuu2YEwmAEBjjcsSzHgZR0=";
}
