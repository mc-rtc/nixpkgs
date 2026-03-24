{
stdenv, symlinkJoin,
jvrc1-mj-description,
env-mj-description,
robots ? []
}:

symlinkJoin {
  name = "mc-mujoco-robots";
  paths = [jvrc1-mj-description env-mj-description] ++ robots;
  meta =
  {
    description = "Robots for mc-mujoco symlinked into a single folder";
  };
}
