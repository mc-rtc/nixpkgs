{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; },
  with-tvm ? false
}:
pkgs.mkShell rec {
  mc-rtc = if with-tvm then pkgs.mc-rtc-tvm else pkgs.mc-rtc;
  buildInputs = builtins.trace mc-rtc.with-tvm [ pkgs.cmake mc-rtc ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    test_dir=$(cd test && pwd);
    tmp_dir=$(mktemp -d)
    cd $tmp_dir
    cmake $test_dir -DCMAKE_BUILD_TYPE=Release
    make
    ./main
  '';
}
