{ stdenv, lib, fetchgit, cmake, mc-rtc, copra }:

stdenv.mkDerivation {
  pname = "lipm-walking-controller";
  version = "1.6.0";

  # master branch as of 2021.01.25
  src = if mc-rtc.with-tvm then
    fetchgit {
      url = "https://github.com/gergondet/lipm_walking_controller";
      rev = "refs/heads/topic/TVM";
      sha256 = "08l16mzbw6hzh2cz2kgwc4zncsw7qfc7k6wqnb7j71ykbc3fs5aw";
    }
    else
    fetchgit {
      url = "https://github.com/arntanguy/lipm_walking_controller";
      rev = "refs/heads/topic/stabilizer";
      sha256 = "107jlxh4kzhx3s69iggv82l8pxifw9cz3413saxp555j75f8wdlp";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-rtc copra ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Walking controller based on linear inverted pendulum tracking";
    homepage    = "https://github.com/jrl-umi3218/lipm_walking_controller";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
