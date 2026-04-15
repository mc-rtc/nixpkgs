{
  with-ros ? true,
  ...
}:
(
  final: prev:
  let
    callWithRos = pkg: args: prev.callPackage pkg (args // { inherit with-ros; });
  in
  {
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
        robots = final.mc-mujoco-robots-public ++ final.mc-mujoco-robots-private;
      };
    };

    mc-rtc-superbuild-private = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = prev.mc-rtc-superbuild-full.superbuildArgs // {
        pname = "mc-rtc-superbuild-private";
        robots = prev.mc-rtc-superbuild-full.superbuildArgs.robots ++ [
          final.mc-hrp2
          final.mc-hrp4
          final.mc-hrp5-p
          # final.mc-rhps1
        ];
      };
    };

    # TODO move to Hugo's
    mc-rtc-superbuild-hugo = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = prev.mc-rtc-superbuild-full.superbuildArgs // {
        pname = "mc-rtc-superbuild-hugo";
        robots = [ final.mc-rhps1 ];
        # observers = [mc-state-observation]; # FIXME missing Attitude observer from mc_state_observation
        controllers = [ final.polytopeController ];
        configs = [ "${final.polytopeController}/lib/mc_controller/etc/mc_rtc.yaml" ];
        plugins = [ final.mc-force-shoe-plugin-hugo ];
        apps = [
          final.mc-rtc-magnum-hugo
          final.mc-mujoco-hugo
        ];
      };
    };
  }
)
