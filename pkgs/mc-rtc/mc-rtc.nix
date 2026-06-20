# Builds the base mc-rtc version, without any plugins (controllers, robots, etc)
# See mc-rtc-superbuild.nix for a full derivation with optional plugins

{
  lib,
  buildRosPackage,
  stdenv,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  pkg-config,
  tasks,
  tvm,
  eigen-quadprog,
  libtool,
  geos,
  spdlog,
  fmt,
  ndcurves,
  mc-rtc-data,
  state-observation,
  nanomsg,
  libnotify,
  rapidjson,
  boost,
  mesh-sampling,
  python3Packages,
  qt5,
  doxygen,
  bundler, # Ruby for bundle dependencies
  with-ros ? false,
  rclcpp ? null,
  nav-msgs ? null,
  sensor-msgs ? null,
  tf2-ros ? null,
  rosbag2 ? null,
  mc-rtc-msgs ? null,
  ament-cmake ? null,
}:

let
  common = import ./mc-rtc-common.nix {
    inherit fetchFromGitHub;
  };
in

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "mc-rtc";
  inherit (common) version src;

  postPatch =
    if with-ros then
      ''
        sed -i 's@set(''${PACKAGE_PATH_VAR} "''${''${PACKAGE}_INSTALL_PREFIX}@\0/share/''${PACKAGE}@' CMakeLists.txt
      ''
    else
      "";

  buildInputs = [
    jrl-cmakemodules
  ];
  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
    python3Packages.distutils
    python3Packages.pytest
    python3Packages.cython
    python3Packages.python
  ]
  ++ [
    # for documentation
    doxygen
    bundler
  ];

  propagatedBuildInputs = [
    pkg-config
    tasks
    eigen-quadprog
    libtool
    geos
    spdlog
    ndcurves
    mc-rtc-data
    state-observation
    nanomsg
    tvm
    libnotify
    rapidjson
    boost
    mesh-sampling
    fmt
    python3Packages.tasks
  ]
  ++
    # for python utils (mc_rtc_new_fsm_controller, mc_log_ui, etc)
    [
      python3Packages.gitpython
      python3Packages.pyqt5
      python3Packages.matplotlib
    ]
  ++ lib.optional (with-ros && rclcpp != null) rclcpp
  ++ lib.optional (with-ros && nav-msgs != null) nav-msgs
  ++ lib.optional (with-ros && sensor-msgs != null) sensor-msgs
  ++ lib.optional (with-ros && tf2-ros != null) tf2-ros
  ++ lib.optional (with-ros && rosbag2 != null) rosbag2
  ++ lib.optional (with-ros && mc-rtc-msgs != null) mc-rtc-msgs
  ++ lib.optional with-ros ament-cmake
  ++ lib.optional with-ros pkg-config;

  preConfigure = ''
    export ROS_VERSION=2
  '';

  cmakeFlags = [
    "-DBUILD_MC_RTC_PYTHON_UTILS=ON"
    "-DBUILD_TESTING=OFF"
    "-DINSTALL_DOCUMENTATION=ON"
  ];

  doCheck = true;

  with-ros = with-ros;

  postInstall = ''
    wrapQtApp $out/bin/mc_log_ui
  '';

  # XXX: Without this fixupPhase fails due to RPATHS references to /build/
  preFixup = ''
    find "$out/${python3Packages.python.sitePackages}" -name "*.so" -type f | while read -r binary; do
      echo "Shrinking RPATH for $binary"
      patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$binary"
    done
  '';

  meta = with lib; {
    description = "An interface for simulated and real robotic systems suitable for real-time control";
    homepage = "https://github.com/jrl-umi3218/mc_rtc";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
