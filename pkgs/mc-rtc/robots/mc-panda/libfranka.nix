{
  stdenv,
  lib,
  fetchgit,
  cmake,
  eigen,
  poco,
  tinyxml-2,
}:

stdenv.mkDerivation {
  pname = "libfranka_0_9_2";
  version = "0.9.2";

  src = fetchgit {
    url = "https://github.com/jrl-umi3218/libfranka";
    rev = "f3bbab62bfbbd64a59cf35d427199963630d5506";
    hash = "sha256-AvAOY9DbzcoOHqvkfL7ADXICX40t+ke+zkunPVcEzVE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    poco
    eigen
    tinyxml-2
  ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=ON"
    "-DBUILD_TESTS=OFF"
  ];

  doCheck = false;

  meta = with lib; {
    description = "C++ library for Franka Robotics research robots";
    homepage = "https://github.com/jrl-umi3218/libfranka";
    license = licenses.asl20;
    # platforms = platforms.linux;
    maintainers = [ ];
  };
}
