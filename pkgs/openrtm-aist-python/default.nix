{ lib, fetchFromGitHub, python2, buildPythonPackage, openrtm-aist, omniorb-python }:

buildPythonPackage rec {
  pname = "openrtm-aist-python";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "gergondet";
    repo = "openrtm-aist-python-deb";
    rev = "master";
    sha256 = "0n4sjva3giw4fj1x70qksmmr421g1qbkf2w5fii9s5ykp208bjic";
  };

  nativeBuildInputs = [ python2 openrtm-aist omniorb-python ];

  doCheck = false;

  meta = with lib; {
    description = "OpenRTM-aist is a software platform developed on the basis of the RT middleware standard.";
    homepage    = "https://www.openrtm.org";
    license     = licenses.lgpl3;
    platforms   = platforms.all;
  };
}
