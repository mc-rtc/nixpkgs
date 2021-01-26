{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; } }:

pkgs.mkShell rec {
  buildInputs = with pkgs; [ cmake mc-rtc-raylib ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
  '';
}
