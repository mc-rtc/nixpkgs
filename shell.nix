{ pkgs }:

let 
  mcRtcConfigs =
  pkgs.mc-rtc-superbuild.configs
  ++ [ "${pkgs.mc-rtc-superbuild}/etc/mc_rtc.yaml" ];
in
pkgs.mkShell {
  buildInputs = 
  with pkgs; [ mc-rtc-superbuild cmake ninja clang clang-tools ]
  ++ (with pkgs.xorg; [ mc-rtc-superbuild assimp libGL libXrandr libXinerama libXcursor libX11 libXi libXext ]);

  shellHook = ''
    export MC_RTC_PATH=${pkgs.mc-rtc}
    export MC_RTC_LIB=${pkgs.mc-rtc}/lib
    export MC_RTC_BIN=${pkgs.mc-rtc}/bin
    export MC_RTC_PKGCONFIG=${pkgs.mc-rtc}/lib/pkgconfig
    export MC_RTC_CONTROLLER_CONFIG=${pkgs.lib.concatStringsSep ":" mcRtcConfigs}

    export PATH=$MC_RTC_BIN:$PATH
    export LD_LIBRARY_PATH=$MC_RTC_LIB:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=$MC_RTC_PKGCONFIG:$PKG_CONFIG_PATH

    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp

    echo "mc-rtc-superbuild interactive shell ready."
    echo "The following convenience environment variables are set:"
    env | grep '^MC_RTC_'

    echo "Runtime dependencies:"
    echo "Robot modules:"
    for robot in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") pkgs.mc-rtc-superbuild.robots)}; do
      echo "  $robot"
    done
    echo "Plugins:"
    for plugin in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") pkgs.mc-rtc-superbuild.plugins)}; do
      echo "  $plugin"
    done
  '';
}
