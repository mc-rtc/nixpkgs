# Builds the base mc-rtc version, without any plugins (controllers, robots, etc)
# See mc-rtc-superbuild.nix for a full derivation with optional plugins

{ stdenv, lib, fetchFromGitHub, fetchgit, cmake, pkg-config,
  tasks, tvm, eigen-quadprog, libtool, geos, spdlog, fmt, ndcurves, mc-rtc-data,
  state-observation, nanomsg, libnotify, rapidjson, boost, mesh-sampling,
  with-ros ? false,
  rclcpp ? null, nav-msgs ? null, sensor-msgs ? null, tf2-ros ? null, rosbag2 ? null, mc-rtc-msgs ? null,
  useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation {
  pname = "mc-rtc";
  version = "2.14.1"; # TODO: Release

  src = if useLocal then
    builtins.trace "Using local workspace for mc_rtc: ${localWorkspace}/mc_rtc"
    (builtins.path {
      path = "${localWorkspace}/mc_rtc";
      name = "mc_rtc-src";
    })
  else
    # TODO: future 2.14.1 release
    fetchgit {
      url = "https://github.com/arntanguy/mc_rtc";
      # topic/nix-ConnectModules, fix runtime paths merging
      rev = "6176587f0778d40c3206bba697090cc3d98c0d91";
      fetchSubmodules = true;
      sha256 = "sha256-KYYoKoW4FOzRJKr/E6GpOHvci75zztDC1nj7yArOAPQ=";
    };

  postPatch = if with-ros then
    ''
      sed -i 's@set(''${PACKAGE_PATH_VAR} "''${''${PACKAGE}_INSTALL_PREFIX}@\0/share/''${PACKAGE}@' CMakeLists.txt
    ''
    else
    "";

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ pkg-config tasks eigen-quadprog libtool geos spdlog fmt ndcurves mc-rtc-data state-observation nanomsg tvm libnotify rapidjson boost mesh-sampling ]
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
}
