{
  lib,
  stdenv,
  cmake,
  pkg-config,
  doxygen,
  boost,
  glfw,
  freeglut,
  libGLU,
  perl,
  fetchgit,
  eigen,
  sch-core,
  useLocal ? false, localWorkspace ? null,
}:

stdenv.mkDerivation rec {
  pname = "sch-visualization";
  version = "1.0.1";

  src = 
    if useLocal then
      builtins.trace "Using local workspace for sch-visualization: ${localWorkspace}/sch-visualization"
      (builtins.path {
        path = "${localWorkspace}/sch-visualization";
        name = "sch-visualization-src";
      })
  else
    fetchgit {
      url = "https://github.com/jrl-umi3218/sch-visualization";
      rev = "a9883a9c2470c0d430306aea2f73284c255c705e";
      hash = "sha256-hHQqPE+ijvXpHdHuHETBPI6O/Q5une+X7YwKdFAzdmg=";
      fetchSubmodules = true;
    };

  nativeBuildInputs = [ cmake doxygen pkg-config perl ];
  propagatedBuildInputs = [ eigen sch-core glfw freeglut boost libGLU ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "sch-visualization: Effective proximity queries";
    homepage    = "https://github.com/jrl-umi3218/sch-visualization";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
