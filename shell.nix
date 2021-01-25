{ pkgs ? import <nixpkgs> { overlays = [ (import ./default.nix) ]; },
  with-tvm ? false
}:

let

my-mc-rtc = with pkgs; mc-rtc.override { with-tvm = with-tvm; plugins = [ mc-state-observation lipm-walking-controller ]; };

in

pkgs.mkShell rec {
  buildInputs = with pkgs; [ cmake my-mc-rtc ];
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
    export mc_rtc=${my-mc-rtc}
    cp $test_dir/mc_rtc.yaml .
    substituteAllInPlace mc_rtc.yaml
    cmake $test_dir -DCMAKE_BUILD_TYPE=Release
    make
    ./main mc_rtc.yaml
  '';
}
