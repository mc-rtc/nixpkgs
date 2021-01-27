{ lib, buildRosPackage, fetchurl, catkin, message-generation, message-runtime, geometry-msgs }:

buildRosPackage {
  pname = "ros-noetic-mc-rtc-msgs";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/jrl-umi3218/mc_rtc_msgs/releases/download/v1.0.1/mc_rtc_msgs-v1.0.1.tar.gz";
    sha256 = "1sfkqns5ncigp3z8zhiv86dwqyd5l6ijx8sbzq9ywipqxh5jnkwr";
  };

  buildType = "catkin";
  buildInputs = [ message-generation ];
  propagatedBuildInputs = [ geometry-msgs message-runtime ];
  nativeBuildInputs = [ catkin ];

  meta = {
    description = "Common messages used by mc_rtc ROS plugin";
    license = with lib.licenses; [ bsd2 ];
  };
}
