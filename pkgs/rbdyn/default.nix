{ stdenv, fetchurl, cmake, spacevecalg, libyamlcpp, tinyxml-2, boost }:

stdenv.mkDerivation {
  pname = "rbdyn";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/RBDyn/releases/download/v1.4.0/RBDyn-v1.4.0.tar.gz";
    sha256 = "1msb2f03wzxqp0w2awijbcnhgfi2vrd3r9v6ib5hwvm9hrjl3a7x";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ spacevecalg libyamlcpp tinyxml-2 boost ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Model the dynamics of rigid body systems";
    homepage    = "https://github.com/jrl-umi3218/RBDyn";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
