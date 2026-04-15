{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  useLocal ? false,
  localWorkspace ? null,
}:

import ./mj-description-base.nix {
  inherit
    stdenv
    lib
    fetchFromGitHub
    cmake
    useLocal
    localWorkspace
    ;
  pname = "g1-mj-description";
  repo = "g1_mj_description";
  hash = "sha256-vm03l9AWxvwJEXgrU0bv8Krf1V1AizHqMxnjXj232K4=";
}
