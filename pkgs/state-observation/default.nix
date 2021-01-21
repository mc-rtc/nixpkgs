{ stdenv, fetchgit, cmake, boost, eigen }:

stdenv.mkDerivation {
  pname = "state-observation";
  version = "1.3.3";

  # current master as of 2021.01.21
  src = fetchgit {
    url = "https://github.com/jrl-umi3218/state-observation";
    rev = "4a6b8eb6fa841cf706a074132fb24b50e8534e35";
    sha256 = "13wazgqak89m24k0g3rignfs6pzacj7ck8nhz2ap8ypbscw024bs";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost eigen ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_STATE_OBSERVATION_TOOLS=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Describes interfaces for state observers, and implements some observers (including linear and extended Kalman filters)";
    homepage    = "https://github.com/jrl-umi3218/state-observation";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
