/**
  - **`final`**: The package set after all overlays have been applied.
    Use this if you want to reference packages as they will appear after your overlay and others are merged.

  - **`prev`**: The package set before your overlay is applied (i.e., the "previous" state).
    Use this to access and override existing packages, or to call functions from the underlying package set.
*/
{
  with-ros ? false,
  ...
}:
(
  final: prev:
  let
    callWithRos = pkg: args: callWithRos pkg (args // { inherit with-ros; });
  in
  {
    inherit (prev.rosPackages.jazzy)
      buildRosPackage
      ament-cmake
      rclcpp
      ros2cli
      ros2run
      ros2launch
      ros2topic
      rosbag2
      rviz2
      nav-msgs
      tf2-ros
      tf2-eigen
      visualization-msgs
      sensor-msgs
      rosidl-default-generators
      rosidl-default-runtime
      rosidl-typesupport-c
      rosidl-typesupport-cpp
      geometry-msgs
      xacro
      ;

    nanomsg = prev.nanomsg.overrideAttrs (_old: rec {
      postPatch = ''
        substituteInPlace cmake/nanomsg-config.cmake.in \
          --replace '@PACKAGE_CMAKE_INSTALL_PREFIX@/' ""
      '';
    });

    spacevecalg = callWithRos ./pkgs/spacevecalg { };
    rbdyn = callWithRos ./pkgs/rbdyn { };
    eigen-qld = callWithRos ./pkgs/eigen-qld { };
    eigen-quadprog = callWithRos ./pkgs/eigen-quadprog { };
    sch-core = callWithRos ./pkgs/sch-core { };
    #sch-visualization = callWithRos ./pkgs/sch-visualization {};
    sch-visualization = callWithRos ./pkgs/sch-visualization { };
    tasks = callWithRos ./pkgs/tasks { };
    # mc-rtc-data = callWithRos ./pkgs/mc-rtc-data { with-ros = false; };
    mc-rtc-data = callWithRos ./pkgs/mc-rtc-data { };
    state-observation = callWithRos ./pkgs/state-observation { };
    mc-rbdyn-urdf = callWithRos ./pkgs/mc-rbdyn-urdf { };
    tvm = callWithRos ./pkgs/tvm { };
    copra = callWithRos ./pkgs/copra { };
    omniorb = prev.symlinkJoin {
      name = "omniorb";
      paths = [
        prev.omniorb.out
        (callWithRos ./pkgs/omniorb-python {
          omniorb = prev.omniorb;
          buildPythonPackage = prev.python2Packages.buildPythonPackage;
        }).out
      ];
    };
    openrtm-aist = callWithRos ./pkgs/openrtm-aist { };
    openrtm-aist-python = callWithRos ./pkgs/openrtm-aist-python {
      buildPythonPackage = prev.python2Packages.buildPythonPackage;
    };
    # mc-state-observation = callWithRos ./pkgs/mc-rtc/observers/mc-state-observation;
    mc-state-observation = callWithRos ./pkgs/mc-rtc/observers/mc-state-observation { };
    #lipm-walking-controller = callWithRos ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
    # lipm-walking-controller = callWithRos ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
    #mc-rtc-raylib = callWithRos ./pkgs/mc-rtc-raylib {};
    mc-rtc-msgs = callWithRos ./pkgs/mc-rtc-msgs { };
    mc-udp = callWithRos ./pkgs/mc-udp { };

    ## Robot description packages
    franka-description = callWithRos ./pkgs/mc-rtc/robots/mc-panda/franka-description.nix { };
    g1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/g1-description.nix { };
    h1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/h1-description.nix { };
    ur-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/ur-description.nix { };
    ur5e-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/ur5e-description.nix { };
    jvrc-description = callWithRos ./pkgs/mc-rtc-data/jvrc-description.nix { };
    mc-env-description = callWithRos ./pkgs/mc-rtc-data/mc-env-description.nix { };
    mc-int-obj-description = callWithRos ./pkgs/mc-rtc-data/mc-int-obj-description.nix { };

    # Robot modules
    mc-g1 = callWithRos ./pkgs/mc-rtc/robots/modules/mc-g1.nix { };
    mc-h1 = callWithRos ./pkgs/mc-rtc/robots/modules/mc-h1.nix { };
    mc-ur5e = callWithRos ./pkgs/mc-rtc/robots/modules/mc-ur5e.nix { };
    mc-panda = callWithRos ./pkgs/mc-rtc/robots/mc-panda { };
    mc-panda-lirmm = callWithRos ./pkgs/mc-rtc/robots/mc-panda/mc-panda-lirmm.nix { };

    libfranka = callWithRos ./pkgs/mc-rtc/robots/mc-panda/libfranka.nix { };
    # mc-franka = callWithRos ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix {};
    mc-franka = callWithRos ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix { };
    poco = callWithRos ./pkgs/mc-rtc/robots/mc-panda/libpoco.nix { };
    mesh-sampling = callWithRos ./pkgs/mesh-sampling { };
    # mesh-sampling = callWithRos ./pkgs/mesh-sampling {};

    # XXX
    # The current nixpkgs input uses fmt_12
    # This breaks both eigen-fmt and PTransformd
    # In mc-rtc fmt is brought in through spdlog. Thus we build an older version
    # 1.12.0 against fmt_9 (technically it supports fmt_10 but nixpkgs used to build it against fmt_9 on purpose). To avoid rebuilding the world, we leave fmt_12 everywhere else,
    # this might cause some headache down the line.
    # TODO: patch mc-rtc and eigen-fmt with fmt_12 support
    mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {
      spdlog = callWithRos ./pkgs/spdlog-1.12.0.nix {
        fmt = final.fmt_9;
      };
    };
    mc-rtc-python-utils = callWithRos ./pkgs/mc-rtc/mc-rtc-python-utils.nix { };
    #mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {};
    mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix {
      inherit with-ros;
    };
    mc-rtc-ticker = callWithRos ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix { };
    gram-savitzky-golay = callWithRos ./pkgs/gram-savitzky-golay { };

    # Hugo's dependencies
    # FIXME: { won't build as-is here as it requires a branch of mc-rtc for now
    # See https://github.com/Hugo-L3174/polytopeController's flake.nix
    # As they are currently not in the flake.nix's package set, this is probably ok to
    # have non-building versions in the overlay (?)
    mc-dynamic-polytopes =
      callWithRos ./pkgs/mc-rtc/controllers/polytopeController/mc-dynamic-polytopes.nix
        {
          jrl-cmakemodules = final.jrl-cmakemodulesv2;
          # mc-rtc = final.mc-rtc-hugo;
        };
    dcm-vrptask = callWithRos ./pkgs/mc-rtc/controllers/polytopeController/dcm-vrptask.nix {
      # mc-rtc = final.mc-rtc-hugo;
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    polytopeController = callWithRos ./pkgs/mc-rtc/controllers/polytopeController/default.nix {
      # mc-rtc = final.mc-rtc-hugo;
    };
    # End of Hugo's dependencies
    # } end of FIXME

    ##########
    #  Apps  #
    ##########
    mujoco = prev.mujoco.overrideAttrs (old: {
      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ final.libGL ];
    });

    jvrc1-mj-description = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/jvrc1-mj-description.nix { };
    g1-mj-description = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/g1-mj-description.nix { };
    h1-mj-description = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/h1-mj-description.nix { };
    ur5e-mj-description = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/ur5e-mj-description.nix { };

    env-mj-description = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/env-mj-description.nix { };

    # symlinkJoin all robots
    # FIXME: this triggers a full rebuild of mc-mujoco
    mc-mujoco = callWithRos ./pkgs/mc-rtc/mc-mujoco {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };

    mc-mujoco-robots = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/default.nix { };
    # mc-mujoco with all public robots
    mc-mujoco-robots-public = callWithRos ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
      robots = [
        final.g1-mj-description
        final.h1-mj-description
        final.ur5e-mj-description
      ];
    };

    ###############
    # CONTROLLERS #
    ###############
    panda-prosthesis = callWithRos ./pkgs/mc-rtc/controllers/panda-prosthesis { };
    # panda-prosthesis = callWithRos ./pkgs/mc-rtc/controllers/panda-prosthesis {};

    ###########
    # PLUGINS #
    ###########
    mc-force-shoe-plugin = callWithRos ./pkgs/mc-rtc/plugins/mc-force-shoe-plugin.nix { };
    mc-robot-model-update = callWithRos ./pkgs/mc-rtc/plugins/mc-robot-model-update.nix { };

    #############
    # 3rd-party #
    #############
    eigen-fmt = callWithRos ./pkgs/3rd-party/eigen-fmt {
      fmt = prev.fmt_10;
    };
    politopix = callWithRos ./pkgs/3rd-party/politopix.nix {
      fetchurl = final.stdenv.fetchurlBoot;
    };

    imguizmo = callWithRos ./pkgs/3rd-party/imguizmo.nix {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    corrade = callWithRos ./pkgs/3rd-party/magnum/corrade.nix { };
    magnum = callWithRos ./pkgs/3rd-party/magnum/magnum.nix { };
    magnum-integration = callWithRos ./pkgs/3rd-party/magnum/magnum-integration.nix {
      with-imguiintegration = true;
    };
    magnum-plugins = callWithRos ./pkgs/3rd-party/magnum/magnum-plugins.nix {
      magnumPluginsWithAssimpImporter = true;
      magnumPluginsWithStbImageImporter = true;
    };
    magnum-with-plugins = callWithRos ./pkgs/3rd-party/magnum/magnum-with-plugins.nix { };
    mc-rtc-imgui = callWithRos ./pkgs/mc-rtc-imgui {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    # standlone version of mc-rtc-magnum, with independent packaging for magnum and its plugins
    # and a standalone mc-rtc-imgui version
    mc-rtc-magnum = callWithRos ./pkgs/mc-rtc-magnum/standalone.nix { };

    #####################
    # mc-rtc-superbuild #
    #####################
    # This derivation provides a mechanism to bring configurations of the whole framework together,
    # that is:
    # - mc-rtc itself
    # - all runtime dependencies controllers/robots/observers/plugins required by the user
    # - a default mc-rtc configuration, e.g which controller/timestep/main robot to use, or if the controllers
    #   provide a suitable mc_rtc.yaml file, it can be referenced here as well
    #
    # This is handled as follows:
    # - all runtime dependencies (including mc-rtc) are built independently, and their output is merged together (symlinkJoin) into a single runtimepath
    # - the default mc_rtc.yaml runtime paths are overridden with corresponding paths in the merged output such that all runtime dependencies are available at the same place (this avoids confusion as to where each runtime dependency is located in the store and makes for a more user-friendly approach). In practice mc_rtc loads this mc_rtc.yaml override through the MC_RTC_CONTROLLER_CONFIG environment variable
    #
    # Note that local out-of-nix overrides from local source folders of controller/robot/plugin/observers can be achieved by:
    # - prefixing LD_LIBRARY_PATH with the local intalled lib path
    # - providing a custom mc_rtc.yaml with ControllerModulePaths, ObserverModulePaths, etc pointing to their corresponding installed folder
    # This is not per-say recomended, but it can drastically reduce build time for these components, and also allow for seamless LSP integration in your editor.
    #
    # TODO: investigate use of ccacheStdenv
    # mc-rtc-superbuild = callWithRos ./pkgs/mc-rtc/mc-rtc-superbuild-symlinkjoin.nix.nix {

    # minimal superbuild environment (jvrc1, mc_rtc_ticker)
    mc-rtc-superbuild-minimal = callWithRos ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = {
        pname = "mc-rtc-superbuild-minimal";
        observers = [ final.mc-state-observation ];
      };
    };

    # default superbuild environment (jvrc1 robot, with gui apps and mujoco simulation)
    mc-rtc-superbuild = callWithRos ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = final.mc-rtc-superbuild-minimal.superbuildArgs // {
        pname = "mc-rtc-superbuild";
        apps = [
          final.mc-rtc-magnum
          final.mc-mujoco
          final.mc-rtc-ticker
        ];
      };
    };

    # default superbuild environment with all public robots (jvrc1, g1, h1, ur5e), with gui apps
    mc-rtc-superbuild-all-public-robots = callWithRos ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = final.mc-rtc-superbuild.superbuildArgs // {
        pname = "mc-rtc-superbuild-all-public-robots";
        robots = final.mc-rtc-superbuild.superbuildArgs.robots ++ [
          final.mc-g1
          final.mc-h1
          final.mc-ur5e
        ];
      };
    };

    # full superbuild environment (all public robots, all default controllers, gui apps, mujoco)
    mc-rtc-superbuild-full = callWithRos ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = final.mc-rtc-superbuild-all-public-robots.superbuildArgs // {
        pname = "mc-rtc-superbuild-full";
      };
    };
  }
)
