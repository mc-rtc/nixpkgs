{
  symlinkJoin,
  jvrc1-mj-description,
  env-mj-description,
  robots ? [ ],
}:

let
  allRobots = [
    jvrc1-mj-description
    env-mj-description
  ]
  ++ robots;
in
symlinkJoin {
  name = "mc-mujoco-robots";
  paths = allRobots;
  passthru = {
    robots = allRobots;
  };
  meta = {
    description = "Robots for mc-mujoco symlinked into a single folder";
  };
}
