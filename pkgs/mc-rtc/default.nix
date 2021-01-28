{ stdenv, fetchgit, cmake,
  tasks, eigen-quadprog, libtool, geos, spdlog, fmt, hpp-spline, mc-rtc-data,
  state-observation, mc-rbdyn-urdf, nanomsg,
  with-tvm ? false, tvm ? null,
  with-ros ? true, roscpp, nav-msgs, sensor-msgs, tf2-ros, rosbag, mc-rtc-msgs,
  plugins ? [], symlinkJoin }:

let

mc-rtc-data' = mc-rtc-data.override {
    with-ros = with-ros;
};

default = stdenv.mkDerivation {
  pname = "mc-rtc";
  version = if with-tvm then "2.0.0" else "1.6.0";

  src = if with-tvm then
    # topic/TVM branch as of 2021.01.28
    fetchgit {
      url = "https://github.com/gergondet/mc_rtc";
      rev = "0dcdcd2d3defa6adfa4724c7b9bac8be8827301c";
      sha256 = "16dp1p9jccmc85p39iqkkhfrs2x9vwhgn1z47rmgvrwbvgn787mz";
    }
  else
    # master branch as of 2021.01.21
    fetchgit {
      url = "https://github.com/jrl-umi3218/mc_rtc";
      rev = "e383426418669292fcb9eea58b26de3e3a22c0fa";
      sha256 = "02azyhdd3fryh50d7cv9s2b7nwxhq9mfhwzz9byik247p8sjw97z";
    };

  postPatch = if with-ros then
    ''
    sed -i 's@set(''${PACKAGE_PATH_VAR} "''${''${PACKAGE}_INSTALL_PREFIX}@\0/share/''${PACKAGE}@' CMakeLists.txt
    ''
    else
    ''
    '';

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ tasks eigen-quadprog libtool geos spdlog fmt hpp-spline mc-rtc-data' state-observation mc-rbdyn-urdf nanomsg ]
  ++ stdenv.lib.optional with-tvm [ tvm ]
  ++ stdenv.lib.optional with-ros [ roscpp nav-msgs sensor-msgs tf2-ros rosbag mc-rtc-msgs];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  with-ros = with-ros;
  with-tvm = with-tvm;

  postInstall = ''
    sed -i 's/''${PACKAGE_PREFIX_DIR}/''${CMAKE_INSTALL_PREFIX}/' $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_RUNTIME_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
    echo 'set(MC_STATES_DEFAULT_LIBRARY_INSTALL_PREFIX "''${PACKAGE_PREFIX_DIR}/lib/mc_controller/fsm/states")' >> $out/lib/cmake/mc_rtc/mc_rtcMacros.cmake
  '';

  meta = with stdenv.lib; {
    description = "An interface for simulated and real robotic systems suitable for real-time control";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
};

in

if plugins == [] then default
else symlinkJoin {
  name = (stdenv.lib.lists.foldl (a: b: a + "+" + b.name) default.name) plugins;
  paths = [ default ] ++ map(p: p.override { mc-rtc = default; }) plugins;
  with-ros = default.with-ros;
  with-tvm = default.with-tvm;
}
