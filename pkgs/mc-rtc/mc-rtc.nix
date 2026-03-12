# Builds the base mc-rtc version, without any plugins (controllers, robots, etc)
# See mc-rtc-superbuild.nix for a full derivation with optional plugins

{ lib, buildRosPackage, stdenv, fetchgit, cmake, pkg-config,
tasks, tvm, eigen-quadprog, libtool, geos, spdlog, fmt, ndcurves, mc-rtc-data,
state-observation, nanomsg, libnotify, rapidjson, boost, mesh-sampling,
python313Packages, qt5,
doxygen, bundler,# Ruby for bundle dependencies
with-ros ? false,
rclcpp ? null, nav-msgs ? null, sensor-msgs ? null, tf2-ros ? null, rosbag2 ? null, mc-rtc-msgs ? null,
useLocal ? false, localWorkspace ? null
}:

let
  common = import ./mc-rtc-common.nix { inherit useLocal localWorkspace fetchgit; };
in

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "mc-rtc";
  inherit (common) version src;

  postPatch = if with-ros then
    ''
      sed -i 's@set(''${PACKAGE_PATH_VAR} "''${''${PACKAGE}_INSTALL_PREFIX}@\0/share/''${PACKAGE}@' CMakeLists.txt
    ''
    else
    "";

    nativeBuildInputs = [ cmake qt5.wrapQtAppsHook ];
  propagatedBuildInputs = [ pkg-config tasks eigen-quadprog libtool geos spdlog fmt ndcurves mc-rtc-data state-observation nanomsg tvm libnotify rapidjson boost mesh-sampling ]
  ++ [ python313Packages.gitpython python313Packages.pyqt5 python313Packages.matplotlib]
  ++ [ doxygen bundler ] # for documentation
    ++ lib.optional (with-ros && rclcpp != null) rclcpp
    ++ lib.optional (with-ros && nav-msgs != null) nav-msgs
    ++ lib.optional (with-ros && sensor-msgs != null) sensor-msgs
    ++ lib.optional (with-ros && tf2-ros != null) tf2-ros
    ++ lib.optional (with-ros && rosbag2 != null) rosbag2
    ++ lib.optional (with-ros && mc-rtc-msgs != null) mc-rtc-msgs;

    preConfigure = ''
      export ROS_VERSION=2
    '';

  cmakeFlags = [
    "-DBUILD_MC_RTC_PYTHON_UTILS=ON"
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=ON"
  ];

  doCheck = true;

  with-ros = with-ros;

  postInstall = ''
    sed -i 's/''${PACKAGE_PREFIX_DIR}/''${CMAKE_INSTALL_PREFIX}/' $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_RUNTIME_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_LIBRARY_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    wrapQtApp $out/bin/mc_log_ui
  '';

  meta = with lib; {
    description = "An interface for simulated and real robotic systems suitable for real-time control";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
