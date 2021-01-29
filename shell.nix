{ pkgs ? import <nixpkgs> { overlays = [ (import ./ros-overlay/overlay.nix) (import ./default.nix) ]; },
  with-ros ? true,
  with-tvm ? false,
  with-udp ? false
}:

let

enabled = "CoM";
main_robot = "JVRC1";

# Here we define a local controller that will be built within the local environment
my-controller = { cmake, mc-rtc }: pkgs.stdenv.mkDerivation {
  pname = "my-controller";
  version = "1.0.0";

  # Shows how the source folder can be changed for mc_rtc 2.0.0 adaptation
  src = if mc-rtc.with-tvm then
      /home/gergondet/devel/src/my_controller
    else
      /home/gergondet/devel/src/my_controller;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ mc-rtc ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;
};

mc-rtc = pkgs.mc-rtc.override {
  with-ros = with-ros;
  with-tvm = with-tvm;
  # These are the package that will be added to your mc_rtc base installation
  # The default configuration (JVRC1 robot and CoM controller) requires no extras
  plugins = with pkgs;
    [
      # Example: bring in HRP2/HRP4/HRP5P/panda
      #          (requires access rights and a correctly configured ssh key for HRP robots)
      # mc-hrp2 mc-hrp4 mc-hrp5-p mc-panda
      # Example: bring in lipm-walking-controller which requires mc-state-observation
      # mc-state-observation
      # lipm-walking-controller
    ];
};

mc-ticker = if with-udp then
  pkgs.mc-udp.override {
    mc-rtc = mc-rtc;
  }
  else
  pkgs.callPackage ({ cmake, mc-rtc }: pkgs.stdenv.mkDerivation {
    pname = "mc-rtc-nix-ticker";
    version = "1.0.0";

    src = ./ticker;

    nativeBuildInputs = [ cmake ];
    buildInputs = [ mc-rtc ];
  }) { mc-rtc = mc-rtc; };

ticker-cmd = if with-udp then "MCUDPControl -f" else "mc-rtc-nix-ticker";

rosbash = if with-ros then pkgs.rosPackages.noetic.rosbash else null;

in

pkgs.mkShell rec {
  buildInputs = [ mc-ticker rosbash ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    etc_dir=$(cd etc && pwd);
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
    export enabled=${enabled}
    export main_robot=${main_robot}
    cp $etc_dir/mc_rtc.yaml .
    substituteAllInPlace mc_rtc.yaml
    ${ticker-cmd} mc_rtc.yaml
    exit
  '';
}
