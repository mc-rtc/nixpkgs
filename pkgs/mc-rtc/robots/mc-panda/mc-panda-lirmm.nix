{
  stdenv,
  lib,
  fetchFromGitHub,
  mc-panda,
  cmake,
}:

let
  version = "1.0.0";
in
stdenv.mkDerivation {
  pname = "mc-panda-lirmm";
  version = "${version}";

  # TODO: release mc-panda-lirmm
  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "mc_panda_lirmm";
    rev = "d53e7990b43fc0ed0345e9e01f808ded7e0eaf4b";
    hash = "sha256-62sF6w2so6Q4J1Ghrn2X56xm+sjXhmF9xZ9XaEK1lUA=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ mc-panda ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
    "-DMC_RTC_HONOR_INSTALL_PREFIX=ON"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Panda RobotModule specialization for LIRMM robots for mc-rtc";
    homepage = "https://github.com/jrl-umi3218/mc_panda_lirmm";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
