{ stdenv, fetchgit, cmake, mc-rtc, assimp, libGL, libXrandr, libXinerama, libXcursor, libX11, libXi, libXext }:

stdenv.mkDerivation {
  pname = "mc-rtc-raylib";
  version = "1.0.0";

  # master branch as of 2021.01.25
  src = fetchgit {
      url = "https://github.com/gergondet/mc_rtc-raylib";
      rev = "refs/heads/master";
      sha256 = "1gf1l2kk5sb87hwy83d5i9in713l3dv8q2s2h9hpms4kmva9zzpd";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-rtc assimp libGL libXrandr libXinerama libXcursor libX11 libXi libXext ];

  postPatch = ''
    echo "install(TARGETS main DESTINATION bin RENAME mc-rtc-raylib)" >> CMakeLists.txt
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "raylib based interface for mc-rtc";
    homepage    = "https://github.com/gergondet/mc_rtc-raylib";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
