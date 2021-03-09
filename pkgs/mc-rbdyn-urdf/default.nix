{ stdenv, lib, fetchurl, cmake, rbdyn, boost }:

stdenv.mkDerivation {
  pname = "mc-rbdyn-urdf";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/mc_rbdyn_urdf/releases/download/v1.1.0/mc_rbdyn_urdf-v1.1.0.tar.gz";
    sha256 = "147xmvrs2gy9cwh5rps9f3zv2707mkfbdkzjw9mh1xgxcp45kp2l";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ rbdyn boost ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "mc-rbdyn-urdf allows one to parse an URDF file and create RBDyn structure from it";
    homepage    = "https://github.com/jrl-umi3218/mc_rbdyn_urdf";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
