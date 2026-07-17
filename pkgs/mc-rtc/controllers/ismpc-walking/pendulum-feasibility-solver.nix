{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodulesv2,
  spacevecalg,
  eigen-quadprog,
}:

stdenv.mkDerivation {
  pname = "pendulum-feasibility-solver";
  version = "0.0.0";

  # TODO: release
  src = fetchFromGitHub {
    owner = "isri-aist";
    repo = "pendulum_feasibility_solver";
    rev = "33552357cce4eb5a80e759be9e5c9a2c7f440126";
    hash = "sha256-E8PKIHBZUkDA6OveDyq9d5d2Xk6kXxMrfA0RhIXRjlw=";
  };

  buildInputs = [ jrl-cmakemodulesv2 ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    spacevecalg
    eigen-quadprog
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
