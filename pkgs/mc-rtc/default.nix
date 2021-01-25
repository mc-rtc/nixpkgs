{ stdenv, fetchgit, cmake, tasks, eigen-quadprog, libtool, geos, spdlog, fmt, hpp-spline, mc-rtc-data, state-observation, mc-rbdyn-urdf, nanomsg, with-tvm ? false, tvm ? null, plugins ? [], symlinkJoin }:

let default = stdenv.mkDerivation {
  pname = "mc-rtc";
  version = if with-tvm then "2.0.0" else "1.6.0";

  src = if with-tvm then
    # topic/TVM branch as of 2021.01.21
    fetchgit {
      url = "https://github.com/gergondet/mc_rtc";
      rev = "b163b299f81a2edc4fb620bc9bc8825e14e40936";
      sha256 = "0yyx0w1pj80ysy23r9r89b0xy4y0zjggi8ydf5h9h222dbv0w50b";
    }
  else
    # master branch as of 2021.01.21
    fetchgit {
      url = "https://github.com/jrl-umi3218/mc_rtc";
      rev = "e383426418669292fcb9eea58b26de3e3a22c0fa";
      sha256 = "02azyhdd3fryh50d7cv9s2b7nwxhq9mfhwzz9byik247p8sjw97z";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ tasks eigen-quadprog libtool geos spdlog fmt hpp-spline mc-rtc-data state-observation mc-rbdyn-urdf nanomsg ]
  ++ stdenv.lib.optional with-tvm tvm;

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

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
}
