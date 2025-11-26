{ pkgs }:

pkgs.mkShell {
  buildInputs = [
    pkgs.cmake
    pkgs.mc-rtc-magnum
    pkgs.nixgl.nixGLIntel
  ];

  shellHook = ''
    export MC_RTC_PATH=${pkgs.mc-rtc}
    export MC_RTC_LIB=${pkgs.mc-rtc}/lib
    export MC_RTC_BIN=${pkgs.mc-rtc}/bin
    export MC_RTC_PKGCONFIG=${pkgs.mc-rtc}/lib/pkgconfig

    export PATH=$MC_RTC_BIN:$PATH
    export LD_LIBRARY_PATH=$MC_RTC_LIB:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=$MC_RTC_PKGCONFIG:$PKG_CONFIG_PATH

    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    echo "Launching mc-rtc-magnum with nixGLNvidia..."
    echo $LD_LIBRARY_PATH
    cat $MC_RTC_PATH/include/mc_rtc/config.h
    nixGLIntel mc-rtc-magnum
    exit
  '';
}
