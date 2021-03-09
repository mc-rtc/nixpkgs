{ stdenv, lib, fetchgit, cmake, with-ros ? false, catkin, buildRosPackage, xacro }:

(if with-ros then buildRosPackage else stdenv.mkDerivation) {
  pname = "hrp4-description";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "git@gite.lirmm.fr:mc-hrp4/hrp4";
    rev = "fd0ae1789d4bce1575b6c618d77619e06c264b57";
  };

  nativeBuildInputs = if with-ros then [ catkin ] else [ cmake ];
  propagatedBuildInputs = if with-ros then [ xacro ] else null;

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "HRP4 urdf and data";
    homepage    = "https://gite.lirmm.fr/mc-hrp4/hrp4";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}

