/**
  - **`final`**: The package set after all overlays have been applied.
    Use this if you want to reference packages as they will appear after your overlay and others are merged.

  - **`prev`**: The package set before your overlay is applied (i.e., the "previous" state).
    Use this to access and override existing packages, or to call functions from the underlying package set.
*/
{
  useLocal ? false,
  localWorkspace ? null,
  with-ros ? false,
  ...
}:
(
  final: prev:
  let
    callWithLocal =
      pkg:
      { ... }@args:
      prev.callPackage pkg (
        {
          inherit useLocal localWorkspace;
        }
        // args
      );
    callWithRos = pkg: args: prev.callPackage pkg (args // { inherit with-ros; });
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

    spacevecalg = prev.callPackage ./pkgs/spacevecalg { };
    rbdyn = prev.callPackage ./pkgs/rbdyn { };
    eigen-qld = prev.callPackage ./pkgs/eigen-qld { };
    eigen-quadprog = prev.callPackage ./pkgs/eigen-quadprog { };
    sch-core = prev.callPackage ./pkgs/sch-core { };
    #sch-visualization = prev.callPackage ./pkgs/sch-visualization {};
    sch-visualization = callWithLocal ./pkgs/sch-visualization { };
    tasks = prev.callPackage ./pkgs/tasks { };
    # mc-rtc-data = prev.callPackage ./pkgs/mc-rtc-data { with-ros = false; };
    mc-rtc-data = callWithRos ./pkgs/mc-rtc-data { };
    state-observation = prev.callPackage ./pkgs/state-observation { };
    mc-rbdyn-urdf = prev.callPackage ./pkgs/mc-rbdyn-urdf { };
    tvm = prev.callPackage ./pkgs/tvm { };
    copra = prev.callPackage ./pkgs/copra { };
    omniorb = prev.symlinkJoin {
      name = "omniorb";
      paths = [
        prev.omniorb.out
        (prev.callPackage ./pkgs/omniorb-python {
          omniorb = prev.omniorb;
          buildPythonPackage = prev.python2Packages.buildPythonPackage;
        }).out
      ];
    };
    openrtm-aist = prev.callPackage ./pkgs/openrtm-aist { };
    openrtm-aist-python = prev.callPackage ./pkgs/openrtm-aist-python {
      buildPythonPackage = prev.python2Packages.buildPythonPackage;
    };
    # mc-state-observation = callWithLocal ./pkgs/mc-rtc/observers/mc-state-observation;
    mc-state-observation = prev.callPackage ./pkgs/mc-rtc/observers/mc-state-observation { };
    #lipm-walking-controller = prev.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
    # lipm-walking-controller = callWithLocal ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
    #mc-rtc-raylib = prev.callPackage ./pkgs/mc-rtc-raylib {};
    mc-rtc-msgs = prev.callPackage ./pkgs/mc-rtc-msgs { };
    mc-udp = prev.callPackage ./pkgs/mc-udp { };

    ## Robot description packages
    franka-description = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/franka-description.nix { };
    g1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/g1-description.nix { };
    h1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/h1-description.nix { };
    ur-description = prev.callPackage ./pkgs/mc-rtc/robots/descriptions/ur-description.nix { };
    ur5e-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/ur5e-description.nix { };
    jvrc-description = callWithRos ./pkgs/mc-rtc-data/jvrc-description.nix { };
    mc-env-description = callWithRos ./pkgs/mc-rtc-data/mc-env-description.nix { };
    mc-int-obj-description = callWithRos ./pkgs/mc-rtc-data/mc-int-obj-description.nix { };

    # Robot modules
    mc-g1 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-g1.nix { };
    mc-h1 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-h1.nix { };
    mc-ur5e = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-ur5e.nix { };
    mc-panda = callWithLocal ./pkgs/mc-rtc/robots/mc-panda { };
    mc-panda-lirmm = callWithLocal ./pkgs/mc-rtc/robots/mc-panda/mc-panda-lirmm.nix { };

    libfranka = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/libfranka.nix { };
    # mc-franka = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix {};
    mc-franka = callWithLocal ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix { };
    poco = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/libpoco.nix { };
    mesh-sampling = prev.callPackage ./pkgs/mesh-sampling { };
    # mesh-sampling = callWithLocal ./pkgs/mesh-sampling {};

    # XXX
    # The current nixpkgs input uses fmt_12
    # This breaks both eigen-fmt and PTransformd
    # In mc-rtc fmt is brought in through spdlog. Thus we build an older version
    # 1.12.0 against fmt_9 (technically it supports fmt_10 but nixpkgs used to build it against fmt_9 on purpose). To avoid rebuilding the world, we leave fmt_12 everywhere else,
    # this might cause some headache down the line.
    # TODO: patch mc-rtc and eigen-fmt with fmt_12 support
    mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {
      spdlog = prev.callPackage ./pkgs/spdlog-1.12.0.nix {
        fmt = final.fmt_9;
      };
    };
    mc-rtc-python-utils = callWithLocal ./pkgs/mc-rtc/mc-rtc-python-utils.nix { };
    #mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {};
    # mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix { inherit useLocal; inherit localWorkspace; };
    mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix { };
    # mc-rtc-ticker = callWithLocal ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
    mc-rtc-ticker = prev.callPackage ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix { };
    # mc-rtc = callWithLocal ./pkgs/mc-rtc/mc-rtc.nix { with-ros = true; };
    # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { };
    # mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
    gram-savitzky-golay = prev.callPackage ./pkgs/gram-savitzky-golay { };

    # Hugo's dependencies
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
    dcm-vrptask = callWithLocal ./pkgs/mc-rtc/controllers/polytopeController/dcm-vrptask.nix {
      # mc-rtc = final.mc-rtc-hugo;
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    polytopeController = prev.callPackage ./pkgs/mc-rtc/controllers/polytopeController/default.nix {
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

    jvrc1-mj-description = callWithLocal ./pkgs/mc-rtc/mc-mujoco/robots/jvrc1-mj-description.nix { };
    g1-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/g1-mj-description.nix { };
    h1-mj-description = callWithLocal ./pkgs/mc-rtc/mc-mujoco/robots/h1-mj-description.nix { };
    ur5e-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/ur5e-mj-description.nix { };

    env-mj-description = callWithLocal ./pkgs/mc-rtc/mc-mujoco/robots/env-mj-description.nix { };

    # symlinkJoin all robots
    # FIXME: this triggers a full rebuild of mc-mujoco
    mc-mujoco = callWithLocal ./pkgs/mc-rtc/mc-mujoco {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };

    mc-mujoco-robots = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix { };
    # mc-mujoco with all public robots
    mc-mujoco-robots-public = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
      robots = [
        final.g1-mj-description
        final.h1-mj-description
        final.ur5e-mj-description
      ];
    };

    ###############
    # CONTROLLERS #
    ###############
    panda-prosthesis = callWithLocal ./pkgs/mc-rtc/controllers/panda-prosthesis { };
    # panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis {};

    ###########
    # PLUGINS #
    ###########
    mc-force-shoe-plugin = callWithLocal ./pkgs/mc-rtc/plugins/mc-force-shoe-plugin.nix { };
    mc-robot-model-update = callWithLocal ./pkgs/mc-rtc/plugins/mc-robot-model-update.nix { };

    #############
    # 3rd-party #
    #############
    eigen-fmt = prev.callPackage ./pkgs/3rd-party/eigen-fmt {
      fmt = prev.fmt_10;
    };
    politopix = prev.callPackage ./pkgs/3rd-party/politopix.nix {
      fetchurl = final.stdenv.fetchurlBoot;
    };

    imguizmo = callWithLocal ./pkgs/3rd-party/imguizmo.nix {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    corrade = prev.callPackage ./pkgs/3rd-party/magnum/corrade.nix { };
    magnum = prev.callPackage ./pkgs/3rd-party/magnum/magnum.nix { };
    magnum-integration = callWithLocal ./pkgs/3rd-party/magnum/magnum-integration.nix {
      with-imguiintegration = true;
    };
    magnum-plugins = callWithLocal ./pkgs/3rd-party/magnum/magnum-plugins.nix {
      magnumPluginsWithAssimpImporter = true;
      magnumPluginsWithStbImageImporter = true;
    };
    magnum-with-plugins = prev.callPackage ./pkgs/3rd-party/magnum/magnum-with-plugins.nix { };
    mc-rtc-imgui = prev.callPackage ./pkgs/mc-rtc-imgui {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    # standlone version of mc-rtc-magnum, with independent packaging for magnum and its plugins
    # and a standalone mc-rtc-imgui version
    mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum/standalone.nix { };

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
    # mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-symlinkjoin.nix.nix {

    # minimal superbuild environment (jvrc1, mc_rtc_ticker)
    mc-rtc-superbuild-minimal = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = {
        pname = "mc-rtc-superbuild-minimal";
        observers = [ final.mc-state-observation ];
      };
    };

    # default superbuild environment (jvrc1 robot, with gui apps and mujoco simulation)
    mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
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
    mc-rtc-superbuild-all-public-robots =
      prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix
        {
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
    mc-rtc-superbuild-full = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix {
      superbuildArgs = final.mc-rtc-superbuild-all-public-robots.superbuildArgs // {
        pname = "mc-rtc-superbuild-full";
      };
    };
  }
)
