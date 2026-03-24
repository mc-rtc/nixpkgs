{
stdenv, symlinkJoin,
jvrc1-mj-description,
env-mj-description,
robots ? [jvrc1-mj-description env-mj-description]
}:

symlinkJoin {
  name = "mc-mujoco-robots";
  paths = robots;
  meta =
  {
    description = "Robots for mc-mujoco symlinked into a single folder";
  };
}
