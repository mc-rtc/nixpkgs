{ pkgs, mc-rtc-superbuild, extraBuildInputs, with-ros ? false }:

let 
  mcRtcConfigs =
  mc-rtc-superbuild.configs
  ++ [ "${mc-rtc-superbuild}/etc/mc_rtc.yaml" ];
in
pkgs.mkShell {
  buildInputs =
    with pkgs; [
      mc-rtc-superbuild
      cmake
      ninja
      gdb
    ]
    ++ [ 
    mc-rtc
  ]
    ++ extraBuildInputs;
    # ++ (if with-ros then [
    #   colcon
    #   # rosPackages.jazzy.ros-core
    #   # rosPackages.jazzy.ament-cmake
    #   rosPackages.jazzy.rclcpp
    #   rosPackages.jazzy.geometry-msgs
    #   rosPackages.jazzy.sensor-msgs
    #   rosPackages.jazzy.tf2-ros
    #   rosPackages.jazzy.xacro
    #   # Add more ROS packages as needed
    # ] else []);

  shellHook = ''
    export MC_RTC_PATH=${pkgs.mc-rtc}
    export MC_RTC_JEKYLL_PLUGINS=${pkgs.mc-rtc}/share/doc/mc-rtc/jekyll/plugins
    export MC_RTC_LIB=${pkgs.mc-rtc}/lib
    export MC_RTC_BIN=${pkgs.mc-rtc}/bin
    export MC_RTC_PKGCONFIG=${pkgs.mc-rtc}/lib/pkgconfig
    # For mc-rtc-superbuild-symlinkjoin
    # export MC_RTC_PATH=${mc-rtc-superbuild}
    # export MC_RTC_JEKYLL_PLUGINS=${mc-rtc-superbuild}/share/doc/_plugins
    # export MC_RTC_LIB=${mc-rtc-superbuild}/lib
    # export MC_RTC_BIN=${mc-rtc-superbuild}/bin
    # export MC_RTC_PKGCONFIG=${mc-rtc-superbuild}/lib/pkgconfig
    export MC_RTC_CONTROLLER_CONFIG=${pkgs.lib.concatStringsSep ":" mcRtcConfigs}

    export PATH=$MC_RTC_BIN:$PATH
    export LD_LIBRARY_PATH=$MC_RTC_LIB:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=$MC_RTC_PKGCONFIG:$PKG_CONFIG_PATH

    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp

    # FIXME this flag gets too huge and gcc fails
    export NIX_CFLAGS_COMPILE=""

    echo "======================================="
    echo "  mc-rtc-superbuild interactive shell  "
    echo "======================================="

    echo ""
    echo "The following convenience environment variables are set:"
    env | grep '^MC_RTC_'
    echo ""

    echo "Runtime dependencies (for information):"
    echo "Robot modules:"
    for robot in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") mc-rtc-superbuild.robots)}; do
      echo "  $robot"
    done
    echo "Plugins:"
    for plugin in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") mc-rtc-superbuild.plugins)}; do
      echo "  $plugin"
    done
    echo "Observers:"
    for observer in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") mc-rtc-superbuild.observers)}; do
      echo "  $observer"
    done
    echo "Controllers:"
    for controller in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") mc-rtc-superbuild.controllers)}; do
      echo "  $controller"
    done
    echo "Apps:"
    for app in ${pkgs.lib.concatStringsSep " " (map (r: "${r}") mc-rtc-superbuild.apps)}; do
      echo "  $app"
    done
    echo ""
    echo "All runtime components are symlinked in MC_RTC_PATH=${mc-rtc-superbuild}"
  '';
}
