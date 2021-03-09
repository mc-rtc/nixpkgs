{ stdenv, lib, fetchgit, cmake, mc-rtc, assimp, libGL, libXrandr, libXinerama, libXcursor, libX11, libXi, libXext }:

stdenv.mkDerivation {
  pname = "mc-rtc-raylib";
  version = "1.0.0";

  # master branch as of 2021.01.26
  src = fetchgit {
      url = "https://github.com/gergondet/mc_rtc-raylib";
      rev = "refs/heads/master";
      sha256 = "0yqinyv7pkqyhdlv0haikmd4b2dhaqqq11wq2pv7dx46zmkqw85g";
    };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-rtc assimp libGL libXrandr libXinerama libXcursor libX11 libXi libXext ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "raylib based interface for mc-rtc";
    homepage    = "https://github.com/gergondet/mc_rtc-raylib";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
