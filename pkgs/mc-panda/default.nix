{ stdenv, lib, fetchgit, cmake, mc-rtc, libfranka, franka-description, xacro } :

stdenv.mkDerivation {
  pname = "mc-panda";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/jrl-umi3218/mc_panda";
    rev = "07a2dcc9257b36fa206ce3d549fb1ede959a54f5";
    sha256 = "09kj3ra42gmsrhw7yv05wf28h35mkny5260aiswn8d44aqpd22nn";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ xacro ];
  propagatedBuildInputs = [ mc-rtc libfranka franka-description ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule for mc-rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_panda";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
