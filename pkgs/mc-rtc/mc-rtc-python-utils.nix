{ lib, buildRosPackage, fetchgit, cmake, python313Packages, mc-rtc, useLocal ? false, localWorkspace ? null,
    rosidl-default-generators,
    geometry-msgs,
    rosidl-default-runtime,
    rosidl-typesupport-c,
    rosidl-typesupport-cpp,
    pkg-config
}:

let
  common = import ./mc-rtc-common.nix { inherit useLocal localWorkspace fetchgit; };
in

#python313Packages.buildPythonPackage {
buildRosPackage {
  pname = "mc-rtc-python-utils";
  inherit (common) version src;
  format = "other"; # built by cmake

  nativeBuildInputs = [ cmake pkg-config ];
  propagatedBuildInputs = [ mc-rtc python313Packages.gitpython ]
  ++
  [
    rosidl-default-generators
    geometry-msgs
    rosidl-default-runtime
    rosidl-typesupport-c
    rosidl-typesupport-cpp
   ];


  cmakeFlags = [
    "-DPROJECT_USE_CMAKE_EXPORT=OFF"
    "-DBUILD_MC_RTC=OFF"
    "-DBUILD_MC_RTC_CPP_UTILS=OFF"
    "-DBUILD_MC_RTC_PYTHON_UTILS=ON"
    "-DBUILD_TESTING=OFF"
    "-DPYTHON_BINDING=OFF"
    "-DINSTALL_DOCUMENTATION=OFF"
  ];

  postPatch = ''
    sed -i 's/set(PROJECT_NAME mc_rtc)/set(PROJECT_NAME mc-rtc-python-utils)/' CMakeLists.txt
    sed -i 's/set(DPROJECT_USE_CMAKE_EXPORT TRUE)/set(DPROJECT_USE_CMAKE_EXPORT FALSE)/' CMakeLists.txt
  '';

  preConfigure = ''
    export ROS_VERSION=2
    export AMENT_PREFIX_PATH=${rosidl-default-generators}/share:${geometry-msgs}/share:${rosidl-default-runtime}/share:${rosidl-typesupport-c}/share:${rosidl-typesupport-cpp}/share:$AMENT_PREFIX_PATH
    export CMAKE_PREFIX_PATH=$AMENT_PREFIX_PATH
    echo "AMENT_PREFIX_PATH=$AMENT_PREFIX_PATH"
    echo "CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH"
  '';
 
  doCheck = false;

  meta = with lib; {
    description = "Python utilities from mc-rtc";
    homepage    = "https://github.com/jrl-umi3218/mc_rtc";
    license     = licenses.bsd2;
    platforms   = platforms.all;
  };
}
