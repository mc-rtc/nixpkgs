{ pkgs }:

let
  enabled = "CoM";
  main_robot = "JVRC1";

  mc-rtc = pkgs.mc-rtc.override {
    with-ros = false;
    plugins = with pkgs; [];
  };

  mc-ticker = pkgs.callPackage ({ cmake, mc-rtc }: pkgs.stdenv.mkDerivation {
    pname = "mc-rtc-nix-ticker";
    version = "1.0.0";
    src = ./ticker;
    nativeBuildInputs = [ cmake ];
    buildInputs = [ mc-rtc ];
  }) { mc-rtc = mc-rtc; };

  ticker-cmd = "mc-rtc-nix-ticker";
in

pkgs.mkShell {
  buildInputs = [ mc-ticker ];
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
    ${ticker-cmd} mc_rtc.yaml
    exit
  '';
}

