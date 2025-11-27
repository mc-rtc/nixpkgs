{ pkgs }:

let
  enabled = "CoM";
  main_robot = "JVRC1";

  mc-rtc = pkgs.mc-rtc.override {
    with-ros = false;
    plugins = with pkgs; [];
  };

in

pkgs.mkShell {
  buildInputs = [ mc-rtc pkgs.clangd ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    etc_dir=$(cd etc && pwd)
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
    export enabled=${enabled}
    export main_robot=${main_robot}
    cp $etc_dir/mc_rtc.yaml .
    substituteAllInPlace mc_rtc.yaml
    mc_rtc_ticker -f mc_rtc.yaml
    exit
  '';
}

