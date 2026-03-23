{ stdenv, lib, fetchFromGitHub,
  cmake,
  useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corrade";
  version = "0.0.0";

  dontBuild = true;

  src = if useLocal then
      builtins.trace "Using local workspace for magnum: ${localWorkspace}/corrade"
      (builtins.path {
        path = "${localWorkspace}/corrade";
        name = "magnum-src";
      })
    else
      fetchFromGitHub {
        owner = "mosra";
        repo = "corrade";
        # 20 year anniversary commit
        rev = "2b7251d8bd8833a12f0d9b8deffca7a290340d3c";
        hash = "sha256-Jm11HY+Hyyf8KG4ET9IC2hEn1jLv0e4SZGo8dA5PYO8=";
      };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [];

  cmakeFlags = [
  ];

  doCheck = false;

  meta = with lib; {
    description = "C++11 multiplatform utility library ";
    homepage    = "https://github.com/msora/corrade";
    license     = licenses.bsd2; # FIXME
    platforms   = platforms.all;
  };
})
