{
  stdenv,
  lib,
  cmake,
  boost,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "politopix";
  version = "1.0.0";

  # XXX: this is built from a private github repository
  src = builtins.trace "politopix is currently a private repository, ask I2S Bordeaux to make it public" (builtins.fetchGit {
    url = "git@github.com:Hugo-L3174/politopix";
    rev = "f625b42de4404eea16aabcf720f2cee19dfdc406";
  });

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-DBOOST_TIMER_ENABLE_DEPRECATED"
  ];

  doCheck = false;

  meta = with lib; {
    description = " Github port of I2S Bordeaux's politopix library ";
    homepage = "https://github.com/Hugo-L3174/politopix";
    license = lib.licenses.gpl3Plus;
    platforms = platforms.all;
  };
})
