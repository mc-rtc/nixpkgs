{ stdenv, lib, fetchFromGitHub, cmake
, useLocal ? false, localWorkspace ? null
}:

import ./mj-description-base.nix {
  inherit stdenv lib fetchFromGitHub cmake useLocal localWorkspace;
  pname = "h1-mj-description";
  repo = "h1_mj_description";
}
