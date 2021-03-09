{ stdenv, lib, fetchurl, cmake, rbdyn, sch-core, eigen-qld }:

stdenv.mkDerivation {
  pname = "tasks";
  version = "1.3.1";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/Tasks/releases/download/v1.3.1/Tasks-v1.3.1.tar.gz";
    sha256 = "042qk1ijbmimwxivbnw0g2calxqgm5dm1r3vivhmw3r15nm1ij3v";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ rbdyn sch-core eigen-qld ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Real-time control for kinematics tree and list of kinematics tree";
    homepage    = "https://github.com/jrl-umi3218/tasks";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
