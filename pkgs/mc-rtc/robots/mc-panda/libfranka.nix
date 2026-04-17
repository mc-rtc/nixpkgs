{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  eigen,
  poco,
  tinyxml-2,
  # , doxygen, graphviz
}:

stdenv.mkDerivation {
  pname = "libfranka";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "libfranka";
    rev = "2695c2626d53655175b180a5bc2d9b448e8c427f";
    hash = "sha256-xkpV/m1HqGOiOmurAVCeP9JkdPTopfI0/Sg/SbrU0mY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    eigen
    poco
    tinyxml-2
  ];
  propagatedBuildInputs = [
    poco
    tinyxml-2
  ];

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
    description = "C++ library for Franka Robotics research robots for version 0.9.2 (jrl-umi3218 fork)";
    homepage = "https://github.com/frankarobotics/libfranka";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
