{ pkgs ? import <nixpkgs> { overlays = [ (import ./ros-overlay/overlay.nix) (import ./default.nix) ]; },
  with-ros ? true,
  with-tvm ? false
}:

let

mc-rtc-data = pkgs.mc-rtc-data.override { with-ros = with-ros; };
mc-rtc = pkgs.mc-rtc.override { with-tvm = with-tvm; plugins = with pkgs; [ mc-state-observation lipm-walking-controller ]; };
rosbash = pkgs.rosPackages.noetic.rosbash;

in

pkgs.mkShell rec {
  buildInputs = [ mc-rtc-data rosbash ];
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
    export mc_rtc=${mc-rtc}
    cp $test_dir/mc_rtc.yaml .
    substituteAllInPlace mc_rtc.yaml
    #cmake $test_dir -DCMAKE_BUILD_TYPE=Release
    #make
    #./main mc_rtc.yaml
  '';
}
