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
  doxygen,
  bundler, # Ruby for bundle dependencies
  with-ros ? false,
  mc-rtc-ros-compat, # for both ros-free and ros version
  with-python-bindings ? true,
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
  # for python utils (mc_rtc_new_fsm_controller, mc_log_ui, etc)
  pythonEnv = python3Packages.python.withPackages (ps: [
    ps.gitpython
  ]);

  fullSrc = fetchFromGitHub {
    owner = "arntanguy";
    repo = "mc_rtc";
    rev = "36dede60306676d92dcee9ee0b338236f730c612";
    hash = "sha256-HcnIQBZy7SsV5VD+zi+1LX/MGk9xfeR3E7voTKBsegw=";
  };
  # # For local Tests
  # fullSrc = builtins.path { path = /home/arnaud/devel/mc-rtc-nix/workspace/mc_rtc; name = "mc_rtc"; };

  # Exclude python utils
  filteredSrc = lib.cleanSourceWith {
    filter =
      name: _type:
      let
        relPath = lib.removePrefix (toString common.src + "/") (toString name);
      in
      !(lib.hasPrefix "utils/python" relPath);
    src = fullSrc;
  };
in

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "mc-rtc";
  inherit (common) version;

  src = builtins.trace (builtins.toJSON filteredSrc) filteredSrc;

  postPatch = (
    lib.optionalString with-ros ''
      sed -i 's@set(''${PACKAGE_PATH_VAR} "''${''${PACKAGE}_INSTALL_PREFIX}@\0/share/''${PACKAGE}@' CMakeLists.txt
    ''
  );

  buildInputs = [
    jrl-cmakemodules
  ];
  nativeBuildInputs = [
    cmake
    # for documentation
    doxygen
    bundler
  ]
  ++ lib.optionals use-python-bindings [
    pythonEnv
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
    mc-rtc-ros-compat
    fmt
  ]
  ++
    # for cython bindings
    lib.optionals use-python-bindings [
      python3Packages.tasks
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
    (lib.cmakeBool "BUILD_MC_RTC_PYTHON_UTILS" false)
    "-DBUILD_TESTING=OFF" # FIXME
    "-DINSTALL_DOCUMENTATION=ON" # Use a different output
  ];

  doCheck = true;

  passthru = {
    inherit with-ros;
    with-python-bindings = use-python-bindings;
    fullSrc = fullSrc;
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
