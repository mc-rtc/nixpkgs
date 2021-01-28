self: super:
{
  inherit (super.rosPackages.noetic)
    buildRosPackage
    catkin
    roscpp
    nav-msgs
    tf2-ros
    sensor-msgs
    rosbag
    message-generation
    message-runtime
    geometry-msgs
    xacro;

  nanomsg = super.nanomsg.overrideAttrs( old : rec {
    postPatch = ''
      substituteInPlace cmake/nanomsg-config.cmake.in \
          --replace '@PACKAGE_CMAKE_INSTALL_PREFIX@/' ""
    '';
  });
  tinyxml-2 = super.tinyxml-2.overrideAttrs( old : rec {
    version = "8.0.0";
    src = super.fetchFromGitHub {
      repo = "tinyxml2";
      owner = "leethomason";
      rev = version;
      sha256 = "0raa8r2hsagk7gjlqjwax95ib8d47ba79n91r4aws2zg8y6ssv1d";
    };
  });
  hpp-spline = super.callPackage ./pkgs/hpp-spline {};
  spacevecalg = super.callPackage ./pkgs/spacevecalg {};
  rbdyn = super.callPackage ./pkgs/rbdyn {};
  eigen-qld = super.callPackage ./pkgs/eigen-qld {};
  eigen-quadprog = super.callPackage ./pkgs/eigen-quadprog {};
  sch-core = super.callPackage ./pkgs/sch-core {};
  tasks = super.callPackage ./pkgs/tasks {};
  mc-rtc-data = super.callPackage ./pkgs/mc-rtc-data {};
  state-observation = super.callPackage ./pkgs/state-observation {};
  mc-rbdyn-urdf = super.callPackage ./pkgs/mc-rbdyn-urdf {};
  tvm = super.callPackage ./pkgs/tvm {};
  mc-rtc = super.callPackage ./pkgs/mc-rtc {};
  copra = super.callPackage ./pkgs/copra {};
  omniorb = super.symlinkJoin {
    name = "omniorb";
    paths = [
      super.omniorb.out
      (super.callPackage ./pkgs/omniorb-python {
        omniorb = super.omniorb;
        buildPythonPackage = super.python2Packages.buildPythonPackage;
      }).out
    ];
  };
  openrtm-aist = super.callPackage ./pkgs/openrtm-aist {};
  openrtm-aist-python = super.callPackage ./pkgs/openrtm-aist-python {
    buildPythonPackage = super.python2Packages.buildPythonPackage;
  };
  mc-state-observation = super.callPackage ./pkgs/mc-rtc/observers/mc-state-observation {};
  lipm-walking-controller = super.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
  mc-rtc-raylib = super.callPackage ./pkgs/mc-rtc-raylib {};
  mc-rtc-msgs = super.callPackage ./pkgs/mc-rtc-msgs {};
  mc-udp = super.callPackage ./pkgs/mc-udp {};
  hrp4-description = super.callPackage ./pkgs/hrp4-description {};
  mc-hrp4 = super.callPackage ./pkgs/mc-hrp4 {};
}
