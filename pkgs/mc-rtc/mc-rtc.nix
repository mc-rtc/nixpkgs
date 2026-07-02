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
  qt,
  doxygen,
  bundler, # Ruby for bundle dependencies
  with-ros ? false,
  with-python-bindings ? true,
  with-python-tools ? true,
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
  use-python-bindings = with-python-bindings && !stdenv.hostPlatform.isDarwin;
  use-python-tools =
    with-python-tools
    && (
      if lib.hasInfix "qtbase-5" qt.qtbase.name then
        true
      else
        builtins.trace "warning: mc-rtc is requesting with-python-tools but it is not compatible with qt6, will build without it." false
    );
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
    qt.qtbase
  ];
  nativeBuildInputs = [
    cmake
    # for documentation
    doxygen
    bundler
  ]
  ++ lib.optional use-python-tools qt.wrapQtAppsHook
  ++ lib.optional (use-python-bindings || use-python-tools) python3Packages.python
  ++ lib.optionals use-python-bindings [
    python3Packages.distutils
    python3Packages.pytest
    python3Packages.cython
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
  ]
  ++
    # for cython bindings
    lib.optionals use-python-bindings [
      python3Packages.tasks
    ]
  # for python utils (mc_rtc_new_fsm_controller, mc_log_ui, etc)
  ++ lib.optionals use-python-tools [
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
    (lib.cmakeBool "PYTHON_BINDING" use-python-bindings)
    (lib.cmakeBool "BUILD_MC_RTC_PYTHON_UTILS" use-python-tools) # does not need bindings
    "-DBUILD_TESTING=OFF" # FIXME
    "-DINSTALL_DOCUMENTATION=ON" # Use a different output
  ];

  doCheck = true;

  passthru = {
    inherit with-ros;
    with-python-tools = use-python-tools;
    with-python-bindings = use-python-bindings;
  };

  # XXX: Without this fixupPhase fails due to RPATHS references to /build/
  preFixup = lib.optionalString use-python-bindings ''
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
