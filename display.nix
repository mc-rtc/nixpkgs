{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; } }:

let

nixGL = fetchTarball "https://github.com/guibou/nixGL/archive/master.tar.gz";

myNixGL = (import "${nixGL}/default.nix" {
    pkgs = pkgs;
}).nixGLNvidia;

in

pkgs.mkShell rec {
  buildInputs = with pkgs; [ cmake mc-rtc-raylib myNixGL ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    nixGLNvidia mc-rtc-raylib
    exit
  '';
}
