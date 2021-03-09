{ stdenv, lib, fetchgit, cmake, mc-rtc }:

stdenv.mkDerivation {
  pname = "mc-state-observation";
  version = "1.0.0";

  # master branch as of 2021.01.25
  src = fetchgit {
    url = "https://github.com/arntanguy/mc_state_observation";
    rev = "6cbb56f85cf041657a7f9c84c096d221cd6ebdb2";
    sha256 = "1lmdy9zayr3s70pqmnqicnly2r5za5f1ing765idyp07009dd3pl";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-rtc ];

  # This requirement implies < 2.0 but in fact it's fine for this one
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'mc_rtc 1.6 REQUIRED' 'mc_rtc REQUIRED'
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Extra mc_rtc observers";
    homepage    = "https://github.com/arntanguy/mc_state_observation";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
