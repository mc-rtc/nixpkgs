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
  mc-panda-lirmm = prev.callPackage ./pkgs/mc-panda/mc-panda-lirmm.nix {};
  # mc-panda-lirmm = callWithLocal ./pkgs/mc-panda/mc-panda-lirmm.nix {};
  mc-franka = prev.callPackage ./pkgs/mc-panda/mc-franka.nix {};
  # mc-franka = callWithLocal ./pkgs/mc-panda/mc-franka.nix {};
  franka-description = prev.callPackage ./pkgs/mc-panda/franka-description.nix {};
  poco = prev.callPackage ./pkgs/mc-panda/libpoco.nix {};
  mesh-sampling = prev.callPackage ./pkgs/mesh-sampling {};
  # mesh-sampling = callWithLocal ./pkgs/mesh-sampling {};
  # mc-rtc = callWithRosLocal ./pkgs/mc-rtc/mc-rtc.nix {};
  mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {};
  # mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix { inherit useLocal; inherit localWorkspace; };
  mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix {};
  # mc-rtc-ticker = callWithLocal ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
  mc-rtc-ticker = prev.callPackage ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
  # mc-rtc = callWithLocal ./pkgs/mc-rtc/mc-rtc.nix { with-ros = true; };
  # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { };
  #mc-rtc-magnum = callWithLocal ./pkgs/mc-rtc-magnum {};
  mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
  # mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
  # panda-prosthesis = callWithLocal ./pkgs/mc-rtc/controllers/panda-prosthesis {};
  panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis {};
  # TODO:
  # - as-is it is a bit hard to understand where all parts of mc-rtc are installed,
  #   since they are all in their own store path. Could we figure out a way to inspect them?
  mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild.nix { 
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
    configs = [ "${panda-prosthesis}/lib/mc_controller/etc/mc_rtc.yaml" ]; # extra mc_rtc.yaml
    observers = [];
    plugins = [ mc-rtc ];
    apps = [ mc-rtc-magnum mc-franka mc-rtc-rviz-panel ];
    # apps = [ mc-rtc-magnum ];
    # apps = [ mc-rtc-magnum ];
  };
})
