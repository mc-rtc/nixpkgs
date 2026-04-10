{ stdenv, lib, fetchgit, cmake, pkg-config
, eigen, poco, tinyxml-2
# , doxygen, graphviz
, useLocal ? false, localWorkspace ? null
}:

stdenv.mkDerivation {
  pname = "libfranka";
  version = "0.9.2";

  src = if useLocal then
    builtins.trace "Using local workspace for libfranka: ${localWorkspace}/libfranka"
    (builtins.path {
      path = "${localWorkspace}/libfranka";
      name = "libfranka-src";
    })
  else
    fetchgit {
      url = "https://github.com/frankarobotics/libfranka";
      rev = "f3b8d775a9c847cab32684c8a316f67867761674";
      sha256 = "sha256-xPzzJ4YlRz7MVRgcZaV3QhlOrUFlajJLaArchBylCQM=";
      fetchSubmodules = true;
    };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ eigen poco tinyxml-2 ];
  propagatedBuildInputs = [ poco tinyxml-2 ];

  # Optional: enable documentation if you want
  # nativeBuildInputs = nativeBuildInputs ++ [ doxygen graphviz ];

  patches = [ ./libfranka-cmake-version.patch ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=14"
    "-DBUILD_EXAMPLES=ON"
    "-DBUILD_TESTS=OFF"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_CMAKEDIR=lib/cmake/Franka"
  ];

  doCheck = false;

  meta = with lib; {
    description = "C++ library for Franka Robotics research robots";
    homepage    = "https://github.com/frankarobotics/libfranka";
    license     = licenses.asl20;
    platforms   = platforms.linux;
    maintainers = [ ];
  };
}
