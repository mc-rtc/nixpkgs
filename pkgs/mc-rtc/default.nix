{ stdenv, lib, fetchgit, cmake, pkg-config,
  tasks, tvm, eigen-quadprog, libtool, geos, spdlog, fmt, ndcurves, mc-rtc-data,
  state-observation, nanomsg, libnotify, rapidjson,
  with-ros ? false,
  rclcpp ? null, nav-msgs ? null, sensor-msgs ? null, tf2-ros ? null, rosbag ? null, mc-rtc-msgs ? null,
  extensions ? [], symlinkJoin,
  useLocal ? false,
  localWorkspace ? null
  }:

let

mc-rtc-data' = mc-rtc-data.override {
    with-ros = with-ros;
};

default = stdenv.mkDerivation {
  pname = "mc-rtc";
  version = "2.14.1"; # TODO: Release

  # src = fetchTarball {
  #     url = "https://github.com/jrl-umi3218/mc_rtc/releases/download/v2.13.0/mc_rtc-v2.13.0.tar.gz";
  #     sha256 = "0sh1wsqrk8zsqclv9nv61dzf3r6g5wfk23b6bi2i7hhf2963sw2f";
  #   };

  src = if useLocal then
    builtins.trace "Using local workspace for mc_rtc: ${localWorkspace}/mc_rtc"
    (builtins.path {
      path = "${localWorkspace}/mc_rtc";
      name = "mc_rtc-src";
    })
  else
    # future 2.14.1 release
    fetchgit {
      url = "https://github.com/arntanguy/mc_rtc";
      rev = "refs/heads/topic/nix";
      fetchSubmodules = true;
      sha256 = "";
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

  # Patch paths with their nix-store counterpart
  # XXX: This should not have been required for paths included within
  # the library (controller, observers, robots, etc)
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

# NOTE:
# If there are extensions, merge their install folders with mc-rtc's
# This is done to ensure that mc-rtc will have access to the extensions at runtime without specific configuration
# (e.g observers, controllers, robots, etc)
if extensions == [] then default
else
  let name = (lib.lists.foldl (a: b: a + "+" + b.name) default.name) extensions; in
builtins.trace ''

${default.name} derivation declares the following extensions:
${builtins.concatStringsSep "\n" (map (e: "- ${e.name}") extensions)}
  Their output will be joined (symlinkJoin) with mc-rtc's in "${name}".
''
  (symlinkJoin {
    name = name; 
    paths = [ default ] ++ map(p: p.override { mc-rtc = default; }) extensions;
    with-ros = default.with-ros;
  })
