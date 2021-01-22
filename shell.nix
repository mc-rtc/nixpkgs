{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; },
  with-tvm ? false
}:
pkgs.mkShell rec {
  buildInputs = with pkgs; [ cmake (mc-rtc.override { with-tvm = with-tvm; }) ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    test_dir=$(cd test && pwd);
    tmp_dir=$(mktemp -d /tmp/mc-rtc-nix.XXXXXXXXXXXX)
    cleanup_build() {
      cd $HOME
      rm -rf $tmp_dir
      return 0
    }
    cleanup_and_exit() {
      cleanup_build
      exit
    }
    trap cleanup_build EXIT
    trap cleanup_and_exit SIGINT
    cd $tmp_dir
    cmake $test_dir -DCMAKE_BUILD_TYPE=Release
    make
    ./main
  '';
}
