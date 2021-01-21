{ stdenv, fetchgit, cmake, tasks, eigen-quadprog, libtool, geos, spdlog, fmt, hpp-spline, mc-rtc-data, state-observation, mc-rbdyn-urdf, nanomsg }:

stdenv.mkDerivation {
  pname = "mc-rtc";
  version = "1.6.0";

  # master branch as of 2021.01.21
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/mc_rtc";
    rev = "e383426418669292fcb9eea58b26de3e3a22c0fa";
    sha256 = "02azyhdd3fryh50d7cv9s2b7nwxhq9mfhwzz9byik247p8sjw97z";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ tasks eigen-quadprog libtool geos spdlog fmt hpp-spline mc-rtc-data state-observation mc-rbdyn-urdf nanomsg ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "An interface for simulated and real robotic systems suitable for real-time control";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
