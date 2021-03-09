{ stdenv, lib, fetchFromGitHub, libuuid, omniorb, which, autoconf, automake, autogen, libtool, python, ccache }:

stdenv.mkDerivation {
  pname = "openrtm-aist";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "gergondet";
    repo = "openrtm-aist-deb";
    rev = "master";
    sha256 = "14xdv5kqkwz9wi1bizzypcsgg2lc7h3n3ssjr9lj0dwxn6m0m6qz";
  };

  nativeBuildInputs = [ autoconf autogen automake which python ccache ];
  propagatedBuildInputs = [ libuuid omniorb libtool ];

  doCheck = false;

  postPatch = ''
    substituteInPlace build/autogen \
      --replace /usr/local/share/aclocal ${libtool.outPath}/share/aclocal
    substituteInPlace configure.ac \
      --replace 'AM_INIT_AUTOMAKE([dist-bzip2 tar-pax])' 'AM_INIT_AUTOMAKE([dist-bzip2 tar-pax subdir-objects])'
    substituteInPlace Makefile.am \
      --replace 'AUTOMAKE_OPTIONS = 1.4' 'AUTOMAKE_OPTIONS = 1.4 subdir-objects'
  '';

  preConfigure = ''
    ./build/autogen;
    patchShebangs .
  '';

  configureFlags = [
    "--enable-static"
    "--without-doxygen"
    "--host=${stdenv.hostPlatform.system}"
    "--build=${stdenv.buildPlatform.system}"
  ];

  meta = with lib; {
    description = "OpenRTM-aist is a software platform developed on the basis of the RT middleware standard.";
    homepage    = "https://www.openrtm.org";
    license     = licenses.lgpl3;
    platforms   = platforms.all;
  };
}
