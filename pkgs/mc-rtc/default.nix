{ stdenv, lib, fetchgit, cmake, pkg-config,
  tasks, tvm, eigen-quadprog, libtool, geos, spdlog, fmt, ndcurves, mc-rtc-data,
  state-observation, nanomsg, libnotify, rapidjson,
  with-ros ? false,
  rclcpp ? null, nav-msgs ? null, sensor-msgs ? null, tf2-ros ? null, rosbag ? null, mc-rtc-msgs ? null,
  plugins ? [], symlinkJoin }:

let

mc-rtc-data' = mc-rtc-data.override {
    with-ros = with-ros;
};

default = stdenv.mkDerivation {
  pname = "mc-rtc";
  version = "2.13.0"; # FIXME: use 2.14.0 but cmake submodule is empty in the release

  # src = fetchTarball {
  #     url = "https://github.com/jrl-umi3218/mc_rtc/releases/download/v2.13.0/mc_rtc-v2.13.0.tar.gz";
  #     sha256 = "0sh1wsqrk8zsqclv9nv61dzf3r6g5wfk23b6bi2i7hhf2963sw2f";
  #   };

  # branch topic/nix on @arntanguy remote
  # mc_rtc 2.14 + fixes for fmt
  src = fetchgit {
    url = "https://github.com/arntanguy/mc_rtc";
    rev = "40ebc0d1dd51c9968064d64bdd2fa7105fa69b33";
    fetchSubmodules = true;
    sha256 = "sha256-qa/eHK72uiBYq4KgT4mdrH5vbsrDiDzvXfAxb9nfwPU=";
  };

  postPatch = if with-ros then
    ''
    sed -i 's@set(''${PACKAGE_PATH_VAR} "''${''${PACKAGE}_INSTALL_PREFIX}@\0/share/''${PACKAGE}@' CMakeLists.txt
    ''
    else
    ''
    '';

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ pkg-config tasks eigen-quadprog libtool geos spdlog fmt ndcurves mc-rtc-data state-observation nanomsg tvm libnotify rapidjson ]
    ++ lib.optional (with-ros && rclcpp != null) rclcpp
    ++ lib.optional (with-ros && nav-msgs != null) nav-msgs
    ++ lib.optional (with-ros && sensor-msgs != null) sensor-msgs
    ++ lib.optional (with-ros && tf2-ros != null) tf2-ros
    ++ lib.optional (with-ros && rosbag != null) rosbag
    ++ lib.optional (with-ros && mc-rtc-msgs != null) mc-rtc-msgs;

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  with-ros = with-ros;

  postInstall = ''
    sed -i 's/''${PACKAGE_PREFIX_DIR}/''${CMAKE_INSTALL_PREFIX}/' $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_RUNTIME_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_LIBRARY_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
  '';

  meta = with lib; {
    description = "An interface for simulated and real robotic systems suitable for real-time control";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
};

in

if plugins == [] then default
else symlinkJoin {
  name = (lib.lists.foldl (a: b: a + "+" + b.name) default.name) plugins;
  paths = [ default ] ++ map(p: p.override { mc-rtc = default; }) plugins;
  with-ros = default.with-ros;
  with-tvm = default.with-tvm;
}
