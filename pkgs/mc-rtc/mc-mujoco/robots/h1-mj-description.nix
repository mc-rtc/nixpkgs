{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

import ./mj-description-base.nix {
  inherit
    stdenv
    lib
    fetchFromGitHub
    cmake
    ;
  pname = "h1-mj-description";
  repo = "h1_mj_description";
}
