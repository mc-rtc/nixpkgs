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
    rclcpp
    nav-msgs
    tf2-ros
    sensor-msgs
    message-generation
    message-runtime
    geometry-msgs
    xacro
    franka-description;

  libfranka = prev.rosPackages.jazzy.libfranka.overrideAttrs (old: {
    src = prev.fetchgit {
      url = "https://github.com/frankaemika/libfranka";
      rev = "f1f46fb008a37eb0d1dba00c971ff7e5a7bfbfd3";
      sha256 = "1dliddjwaq30fjqc0zvy89c94vmkyxgmgk9k1kamnkhfip6ilmlv";
    };
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ prev.zlib prev.pcre ];
  });

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
  lipm-walking-controller = prev.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
  #mc-rtc-raylib = prev.callPackage ./pkgs/mc-rtc-raylib {};
  mc-rtc-magnum = callWithLocal ./pkgs/mc-rtc-magnum;
  mc-rtc-msgs = prev.callPackage ./pkgs/mc-rtc-msgs {};
  mc-udp = prev.callPackage ./pkgs/mc-udp {};
  hrp4-description = prev.callPackage ./pkgs/hrp4-description {};
  mc-hrp4 = prev.callPackage ./pkgs/mc-hrp4 {};
  hrp2-description = prev.callPackage ./pkgs/hrp2-description {};
  mc-hrp2 = prev.callPackage ./pkgs/mc-hrp2 { };
  hrp5-p-description = prev.callPackage ./pkgs/hrp5-p-description {};
  mc-hrp5-p = prev.callPackage ./pkgs/mc-hrp5-p {};
  mc-panda = prev.callPackage ./pkgs/mc-panda {};
  mc-rtc = callWithLocal ./pkgs/mc-rtc/mc-rtc.nix {};
  mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild.nix { 
    mc-rtc = final.mc-rtc;
    robots = [ mc-hrp2 ];
    MainRobot = "HRP2DRC";
    controllers = [];
    Enabled = "Posture";
    observers = [];
    plugins = [];
  };
})
