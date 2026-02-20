/**
- **`final`**: The package set after all overlays have been applied.
  Use this if you want to reference packages as they will appear after your overlay and others are merged.

- **`prev`**: The package set before your overlay is applied (i.e., the "previous" state).
  Use this to access and override existing packages, or to call functions from the underlying package set.
*/
{ useLocal ? false, localWorkspace ? null, ... }:
(final: prev:
let
  callWithLocal = pkg: { ... }@args:
    prev.callPackage pkg ({
      inherit useLocal localWorkspace;
    } // args);
in rec
{
  inherit (prev.rosPackages.jazzy)
    buildRosPackage
    ament-cmake
    rclcpp
    nav-msgs
    tf2-ros
    sensor-msgs
    message-generation
    message-runtime
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
  tasks = prev.callPackage ./pkgs/tasks {};
  mc-rtc-data = prev.callPackage ./pkgs/mc-rtc-data {};
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
  hrp4-description = prev.callPackage ./pkgs/hrp4-description {};
  mc-hrp4 = prev.callPackage ./pkgs/mc-hrp4 {};
  hrp2-description = prev.callPackage ./pkgs/hrp2-description {};
  # hrp2-description = callWithLocal ./pkgs/hrp2-description {};
  mc-hrp2 = prev.callPackage ./pkgs/mc-hrp2 { };
  # mc-hrp2 = callWithLocal ./pkgs/mc-hrp2 { };
  hrp5-p-description = prev.callPackage ./pkgs/hrp5-p-description {};
  mc-hrp5-p = prev.callPackage ./pkgs/mc-hrp5-p {};
  libfranka = prev.callPackage ./pkgs/mc-panda/libfranka.nix {};
  mc-panda = prev.callPackage ./pkgs/mc-panda {};
  # mc-panda = callWithLocal ./pkgs/mc-panda {};
  mc-panda-lirmm = prev.callPackage ./pkgs/mc-panda/mc-panda-lirmm.nix {};
  # mc-panda-lirmm = callWithLocal ./pkgs/mc-panda/mc-panda-lirmm.nix {};
  mc-franka = prev.callPackage ./pkgs/mc-panda/mc-franka.nix {};
  # mc-franka = callWithLocal ./pkgs/mc-panda/mc-franka.nix {};
  franka-description = prev.callPackage ./pkgs/mc-panda/franka-description.nix {};
  poco = prev.callPackage ./pkgs/mc-panda/libpoco.nix {};
  mesh-sampling = prev.callPackage ./pkgs/mesh-sampling {};
  # mesh-sampling = callWithLocal ./pkgs/mesh-sampling {};
  mc-rtc = callWithLocal ./pkgs/mc-rtc/mc-rtc.nix { };
  # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { };
  # mc-rtc-magnum = callWithLocal ./pkgs/mc-rtc-magnum {};
  mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
  panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis {};
  # panda-prosthesis = callWithLocal ./pkgs/mc-rtc/controllers/panda-prosthesis {};
  # TODO:
  # - as-is it is a bit hard to understand where all parts of mc-rtc are installed,
  #   since they are all in their own store path. Could we figure out a way to inspect them?
  mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild.nix { 
    robots = [
      mc-hrp2
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
    plugins = [];
    apps = [ mc-rtc-magnum mc-franka ];
  };
})
