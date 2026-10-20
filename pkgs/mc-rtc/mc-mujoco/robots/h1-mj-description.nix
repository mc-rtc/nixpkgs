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
  version = "1.1.0";
  repo = "h1_mj_description";
  hash = "sha256-HmK5B4OmR+Eeyilq6yN4FakIIQXPucC12UACFQMPEoU=";
}
// {
  passthru = {
    robot = {
      module = "mc-g1";
    };
  };
}
