{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, openssl_1_1, zlib, pcre, expat }:

stdenv.mkDerivation rec {
  pname = "poco";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "pocoproject";
    repo = "poco";
    rev = "poco-1.10.1-release";
    sha256 = "sha256-60XBC2cAX/v33cNh9JRvhDXpMTSeVDN6dvFGYawrQpE=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ openssl_1_1 zlib pcre expat ];

  cmakeFlags = [
    "-DENABLE_TESTS=OFF"
    "-DENABLE_SAMPLES=OFF"
    "-DENABLE_DATA_MYSQL=OFF"
    "-DENABLE_DATA_ODBC=OFF"
    "-DENABLE_DATA_POSTGRESQL=OFF"
    "-DENABLE_MONGODB=OFF"
    "-DENABLE_REDIS=OFF"
    "-DENABLE_PDF=OFF"
    "-DENABLE_PAGECOMPILER=OFF"
    "-DENABLE_PAGECOMPILER_FILE2PAGE=OFF"
    "-DENABLE_APACHECONNECTOR=OFF"
    "-DENABLE_CPPPARSER=OFF"
    "-DENABLE_ENCODINGS=OFF"
    "-DENABLE_ENCODINGS_COMPILER=OFF"
    "-DENABLE_JSON=ON"
    "-DENABLE_XML=ON"
    "-DENABLE_UTIL=ON"
    "-DENABLE_NET=ON"
    "-DENABLE_NETSSL=ON"
    "-DENABLE_CRYPTO=ON"
    "-DENABLE_DATA=ON"
    "-DENABLE_DATA_SQLITE=ON"
    "-DENABLE_ZIP=ON"
    "-DENABLE_SEVENZIP=OFF"
    "-DENABLE_JWT=ON"
  ];

  meta = with lib; {
    description = "Modern, powerful open source C++ class libraries for building network- and internet-based applications";
    homepage = "https://pocoproject.org/";
    license = licenses.boost;
    platforms = platforms.unix;
    maintainers = [];
  };
}
