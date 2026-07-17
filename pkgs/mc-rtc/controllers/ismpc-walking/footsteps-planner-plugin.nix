{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  mc-rtc,
  jrl-cmakemodulesv2,
}:

stdenv.mkDerivation {
  pname = "footsteps-planner-plugin";
  version = "0.0.0";

  # TODO: release
  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "footsteps_planner";
    rev = "0284df685b7ba0c5191a5cd1ca20fbcb2dc56850";
    hash = "sha256-On3cRrJrzs20OLTWSWfVX1DGUUqSbePKxhYhTE9EThg=";
  };

  buildInputs = [ jrl-cmakemodulesv2 ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
  ];

  doCheck = true;

  meta = with lib; {
    description = "Linear Inverted Pendulum based footsteps location and steps timing adptation for Bipedal Locomotion.";
    homepage = "https://github.com/antodld/pendulum_feasibility_solver";
    # TODO: add licence
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
