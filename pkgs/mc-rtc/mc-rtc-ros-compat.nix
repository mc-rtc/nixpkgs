{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  catch2_3,
  with-ros ? true,
  buildRosPackage,
  rclcpp,
  ament-cmake, # for ament-index-cpp
  human-description ? null, # for tests
}:

builtins.trace "Building mc-rtc-ros-compat (with-ros: ${lib.boolToString with-ros})"
  (if with-ros then buildRosPackage else stdenv.mkDerivation)
  {
    pname = "mc-rtc-ros-compat";
    version = "1.1.0";

    src = fetchFromGitHub {
      owner = "jrl-umi3218";
      repo = "mc_rtc_ros_compat";
      tag = "v1.1.0";
      hash = "sha256-UW3QxN86nd0072cvAl8dxkoyS9EDEHxMEBK/mWtLvek=";
    };

    dontWrapQtApps = true;
    buildInputs = [
      jrl-cmakemodules
    ];
    nativeBuildInputs = [
      cmake
      catch2_3
    ]
    # for tests
    ++ lib.optional (human-description != null) human-description;
    propagatedBuildInputs = lib.optionals with-ros [
      rclcpp
      ament-cmake
    ];

    cmakeFlags = [
      (lib.cmakeBool "DISABLE_ROS" (!with-ros))
      (lib.cmakeBool "BUILD_TESTS_WITH_ROS_PACKAGES" (human-description != null))
    ];

    doCheck = true;

    meta = with lib; {
      description = "mc-rtc-ros-compat: small library to keep mc-rtc ros-agnostic";
      homepage = "https://github.com/jrl-umi3218/mc_rtc_ros_compat";
      license = licenses.bsd2;
      platforms = platforms.all;
    };
  }
