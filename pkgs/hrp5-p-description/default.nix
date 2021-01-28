{ stdenv, fetchgit, cmake, with-ros ? false, catkin, buildRosPackage }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "hrp5-p-description";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@gite.lirmm.fr:mc-hrp5/hrp5_p_description";
    rev = "e063ba6c04be80746c39c7e7c4b2b45b0443c469";
  };

  nativeBuildInputs = if with-ros then [ catkin ] else [ cmake ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "HRP5P urdf and data";
    homepage    = "https://gite.lirmm.fr/mc-hrp5/hrp5_p_description";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}

