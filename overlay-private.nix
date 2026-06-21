{
  with-ros ? true,
  with-python ? true,
  ...
}:
(
  final: prev:
  let
    callWithRos = pkg: args: prev.callPackage pkg (args // { inherit with-ros; });
  in
  {
    eigen-lssol = prev.callPackage ./pkgs/eigen-lssol/default.nix { };
    hrp2-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/hrp2-description.nix { };
    hrp4-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/hrp4-description.nix { };
    hrp5-p-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/hrp5-p-description.nix { };
    rhps1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/rhps1-description.nix { };
    mc-hrp2 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-hrp2.nix { };
    mc-hrp4 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-hrp4.nix { };
    mc-hrp5-p = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-hrp5-p.nix { };
    mc-rhps1 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-rhps1.nix { };

    rhps1-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/rhps1-mj-description.nix { };
    hrp4-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/hrp4-mj-description.nix { };
    hrp5p-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/hrp5p-mj-description.nix { };
    # TODO: hrp2-mj-description does not exist

    tasks-lssol = prev.callPackage ./pkgs/tasks {
      with-lssol = true;
      inherit with-python;
    };
    # make tasks with lssol the new default
    tasks = final.tasks-lssol;

    # mc-rtc with lssol
    mc-rtc = prev.mc-rtc.override {
      tasks = final.tasks-lssol;
      with-python-bindings = with-python;
      with-python-tools = true;
    };
    # TODO ask I2S Bordeaux to make it public
    # Hugo's dependencies
    politopix = prev.callPackage ./pkgs/3rd-party/politopix.nix { };

    # FIXME: { won't build as-is here as it requires a branch of mc-rtc for now
    # See https://github.com/Hugo-L3174/polytopeController's flake.nix
    # As they are currently not in the flake.nix's package set, this is probably ok to
    # have non-building versions in the overlay (?)
    mc-dynamic-polytopes =
      prev.callPackage ./pkgs/mc-rtc/controllers/polytopeController/mc-dynamic-polytopes.nix
        {
          jrl-cmakemodules = final.jrl-cmakemodulesv2;
          # mc-rtc = final.mc-rtc-hugo;
        };
    dcm-vrptask = prev.callPackage ./pkgs/mc-rtc/controllers/polytopeController/dcm-vrptask.nix {
      # mc-rtc = final.mc-rtc-hugo;
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    polytopeController = prev.callPackage ./pkgs/mc-rtc/controllers/polytopeController/default.nix {
      # mc-rtc = final.mc-rtc-hugo;
    };
    # End of Hugo's dependencies
    # } end of FIXME

    # mc-mujoco with private robots
    mc-mujoco-robots-private = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
      robots = [
        final.rhps1-mj-description
        final.hrp4-mj-description
        final.hrp5p-mj-description
        # NOTE: hrp2-mj-description does not exist
      ];
    };

    mc-mujoco-full = prev.callPackage ./pkgs/mc-rtc/mc-mujoco {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
      mc-mujoco-robots = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
        robots = final.mc-mujoco-robots-public.robots ++ final.mc-mujoco-robots-private.robots;
      };
    };
  }
)
