/**
- **`final`**: The package set after all overlays have been applied.
  Use this if you want to reference packages as they will appear after your overlay and others are merged.

- **`prev`**: The package set before your overlay is applied (i.e., the "previous" state).
  Use this to access and override existing packages, or to call functions from the underlying package set.
*/
{ useLocal ? false, localWorkspace ? null, with-ros ? false, ... }:
(final: prev:
let
  callWithLocal = pkg: { ... }@args:
    prev.callPackage pkg ({
      inherit useLocal localWorkspace;
    } // args);
  callWithRos = pkg: args: prev.callPackage pkg (args // { inherit with-ros; });
  callWithRosLocal = pkg: args: prev.callPackage pkg (args // { inherit with-ros useLocal localWorkspace; });
in rec
{
  inherit (prev.rosPackages.jazzy)
    buildRosPackage
    ament-cmake
    rclcpp
    ros2cli
    ros2run
    ros2launch
    rosbag2
    rviz2
    nav-msgs
    tf2-ros
    visualization-msgs
    sensor-msgs
    rosidl-default-generators
    rosidl-default-runtime
    rosidl-typesupport-c
    rosidl-typesupport-cpp
    geometry-msgs
    xacro;

  nanomsg = prev.nanomsg.overrideAttrs (old: rec {
    postPatch = ''
      substituteInPlace cmake/nanomsg-config.cmake.in \
        --replace '@PACKAGE_CMAKE_INSTALL_PREFIX@/' ""
    '';
  });

  spacevecalg = prev.callPackage ./pkgs/spacevecalg {};
  rbdyn = prev.callPackage ./pkgs/rbdyn {};
  eigen-qld = prev.callPackage ./pkgs/eigen-qld {};
  eigen-quadprog = prev.callPackage ./pkgs/eigen-quadprog {};
  sch-core = prev.callPackage ./pkgs/sch-core {};
  #sch-visualization = prev.callPackage ./pkgs/sch-visualization {};
  sch-visualization = callWithLocal ./pkgs/sch-visualization {};
  tasks = prev.callPackage ./pkgs/tasks {};
  mc-env-description = callWithRos ./pkgs/mc-rtc-data/mc-env-description.nix {};
  mc-int-obj-description = callWithRos ./pkgs/mc-rtc-data/mc-int-obj-description.nix {};
  jvrc-description = callWithRos ./pkgs/mc-rtc-data/jvrc-description.nix {};
  # mc-rtc-data = prev.callPackage ./pkgs/mc-rtc-data { with-ros = false; };
  mc-rtc-data = callWithRos ./pkgs/mc-rtc-data {};
  state-observation = prev.callPackage ./pkgs/state-observation {};
  mc-rbdyn-urdf = prev.callPackage ./pkgs/mc-rbdyn-urdf {};
  tvm = prev.callPackage ./pkgs/tvm {};
  copra = prev.callPackage ./pkgs/copra {};
  omniorb = prev.symlinkJoin {
    name = "omniorb";
    paths = [
      prev.omniorb.out
      (prev.callPackage ./pkgs/omniorb-python {
        omniorb = prev.omniorb;
        buildPythonPackage = prev.python2Packages.buildPythonPackage;
      }).out
    ];
  };
  openrtm-aist = prev.callPackage ./pkgs/openrtm-aist {};
  openrtm-aist-python = prev.callPackage ./pkgs/openrtm-aist-python {
    buildPythonPackage = prev.python2Packages.buildPythonPackage;
  };
  # mc-state-observation = callWithLocal ./pkgs/mc-rtc/observers/mc-state-observation;
  mc-state-observation = prev.callPackage ./pkgs/mc-rtc/observers/mc-state-observation {};
  #lipm-walking-controller = prev.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
  # lipm-walking-controller = callWithLocal ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
  #mc-rtc-raylib = prev.callPackage ./pkgs/mc-rtc-raylib {};
  mc-rtc-msgs = prev.callPackage ./pkgs/mc-rtc-msgs {};
  mc-udp = prev.callPackage ./pkgs/mc-udp {};
  hrp4-description = callWithRos ./pkgs/hrp4-description {};
  mc-hrp4 = prev.callPackage ./pkgs/mc-hrp4 {};
  hrp2-description = callWithRos ./pkgs/hrp2-description {};
  # hrp2-description = callWithLocal ./pkgs/hrp2-description {};
  mc-hrp2 = prev.callPackage ./pkgs/mc-hrp2 { };
  # mc-hrp2 = callWithLocal ./pkgs/mc-hrp2 { };
  hrp5-p-description = callWithRos ./pkgs/hrp5-p-description {};
  mc-hrp5-p = prev.callPackage ./pkgs/mc-hrp5-p {};
  libfranka = prev.callPackage ./pkgs/mc-panda/libfranka.nix {};
  # mc-panda = callWithRosLocal ./pkgs/mc-panda {};
  mc-panda = callWithRos ./pkgs/mc-panda {};
  # mc-panda = callWithLocal ./pkgs/mc-panda {};
  # mc-panda-lirmm = prev.callPackage ./pkgs/mc-panda/mc-panda-lirmm.nix {};
  mc-panda-lirmm = callWithLocal ./pkgs/mc-panda/mc-panda-lirmm.nix {};
  # mc-franka = prev.callPackage ./pkgs/mc-panda/mc-franka.nix {};
  mc-franka = callWithLocal ./pkgs/mc-panda/mc-franka.nix {};
  franka-description = prev.callPackage ./pkgs/mc-panda/franka-description.nix {};
  poco = prev.callPackage ./pkgs/mc-panda/libpoco.nix {};
  mesh-sampling = prev.callPackage ./pkgs/mesh-sampling {};
  # mesh-sampling = callWithLocal ./pkgs/mesh-sampling {};
  mc-rtc = callWithRosLocal ./pkgs/mc-rtc/mc-rtc.nix {};
  mc-rtc-python-utils = callWithLocal ./pkgs/mc-rtc/mc-rtc-python-utils.nix {};
  #mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {};
  # mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix { inherit useLocal; inherit localWorkspace; };
  mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix {};
  # mc-rtc-ticker = callWithLocal ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
  mc-rtc-ticker = prev.callPackage ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
  # mc-rtc = callWithLocal ./pkgs/mc-rtc/mc-rtc.nix { with-ros = true; };
  # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { };
  #mc-rtc-magnum = callWithLocal ./pkgs/mc-rtc-magnum {};
  mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
  # mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
  panda-prosthesis = callWithLocal ./pkgs/mc-rtc/controllers/panda-prosthesis {};
  # panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis {};

  #####################
  # mc-rtc-superbuild #
  #####################
  # This derivation provides a mechanism to bring configurations of the whole framework together,
  # that is:
  # - mc-rtc itself
  # - all runtime dependencies controllers/robots/observers/plugins required by the user
  # - a default mc-rtc configuration, e.g which controller/timestep/main robot to use, or if the controllers
  #   provide a suitable mc_rtc.yaml file, it can be referenced here as well
  #
  # This is handled as follows:
  # - all runtime dependencies (including mc-rtc) are built independently, and their output is merged together (symlinkJoin) into a single runtimepath
  # - the default mc_rtc.yaml runtime paths are overridden with corresponding paths in the merged output such that all runtime dependencies are available at the same place (this avoids confusion as to where each runtime dependency is located in the store and makes for a more user-friendly approach). In practice mc_rtc loads this mc_rtc.yaml override through the MC_RTC_CONTROLLER_CONFIG environment variable
  #
  # Note that local out-of-nix overrides from local source folders of controller/robot/plugin/observers can be achieved by:
  # - prefixing LD_LIBRARY_PATH with the local intalled lib path
  # - providing a custom mc_rtc.yaml with ControllerModulePaths, ObserverModulePaths, etc pointing to their corresponding installed folder
  # This is not per-say recomended, but it can drastically reduce build time for these components, and also allow for seamless LSP integration in your editor.
  #
  # TODO: investigate use of ccacheStdenv
  # mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-symlinkjoin.nix.nix { 
  mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix { 
    robots = [
      # mc-hrp2
      mc-panda
      mc-panda-lirmm
      # note that panda-prosthesis is not strictly-speaking a robot, but it builds a robot module so we need it here as well to populate the robots runtime paths
      panda-prosthesis
    ];
    # MainRobot = "HRP2DRC";
    # Enabled = "CoM";
    # controllers = [lipm-walking-controller];
    controllers = [ panda-prosthesis ];
    # extra mc_rtc.yaml
    configs = [ "${panda-prosthesis}/lib/mc_controller/etc/mc_rtc.yaml" ];
    observers = [];
    plugins = [ panda-prosthesis ];
    apps = [ mc-rtc-magnum mc-franka mc-rtc-rviz-panel sch-visualization ];
    # apps = [ mc-rtc-magnum mc-franka sch-visualization ];
    # apps = [ mc-rtc-magnum ];
  };
})
