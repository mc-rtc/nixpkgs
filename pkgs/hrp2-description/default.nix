{ stdenv, lib, fetchgit, cmake, with-ros ? false, catkin, buildRosPackage }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "hrp2-description";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@gite.lirmm.fr:mc-hrp2/hrp2_drc";
    rev = "240abab83fd77aaeb3e95c18a396ffea37c677e3";
  };

  nativeBuildInputs = if with-ros then [ catkin ] else [ cmake ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP2 urdf and data";
    homepage    = "https://gite.lirmm.fr/mc-hrp2/hrp2_drc";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}

