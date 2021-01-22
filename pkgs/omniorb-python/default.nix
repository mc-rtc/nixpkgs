{ lib, fetchurl, python2, buildPythonPackage, omniorb }:

buildPythonPackage rec {

  pname = "omniorb-python";

  version = omniorb.version;

  src = fetchurl {
    url = "mirror://sourceforge/project/omniorb/omniORBpy/omniORBpy-${version}/omniORBpy-${version}.tar.bz2";
    sha256 = "1di73mx9m639adsjzmf234zwdfzsswdc0svm5c039jcwamkxis6s";
  };

  buildInputs = [ python2 ];
  propagatedBuildInputs = [ omniorb ];

  format = "other";

  configureFlags = [
    "--with-omniorb=${omniorb.outPath}"
  ];

  meta = with lib; {
    description = "A robust high performance CORBA ORB for C++ and Python. It is freely available under the terms of the GNU Lesser General Public License (for the libraries), and GNU General Public License (for the tools). omniORB is largely CORBA 2.6 compliant";
    homepage    = "http://omniorb.sourceforge.net/";
    license     = licenses.gpl2Plus;
    platforms   = platforms.unix;
  };
}
