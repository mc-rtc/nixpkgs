/**
  - **`final`**: The package set after all overlays have been applied.
    Use this if you want to reference packages as they will appear after your overlay and others are merged.

  - **`prev`**: The package set before your overlay is applied (i.e., the "previous" state).
    Use this to access and override existing packages, or to call functions from the underlying package set.
*/
{
  lib,
  with-ros ? false,
  with-python ? true,
  qt, # qt5 or qt6
  ...
}:
(
  final: prev:
  let
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

    eigen3-to-python = prev.callPackage ./pkgs/eigen3-to-python { };
    spacevecalg = prev.callPackage ./pkgs/spacevecalg { inherit with-python; };
    rbdyn = prev.callPackage ./pkgs/rbdyn { inherit with-python; };
    eigen-qld = prev.callPackage ./pkgs/eigen-qld { };
    eigen-quadprog = prev.callPackage ./pkgs/eigen-quadprog { };
    sch-core = prev.callPackage ./pkgs/sch-core { };
    sch-core-python = prev.callPackage ./pkgs/sch-core-python { };
    #sch-visualization = prev.callPackage ./pkgs/sch-visualization {};
    sch-visualization = prev.callPackage ./pkgs/sch-visualization { };
    tasks-qld = prev.callPackage ./pkgs/tasks { inherit with-python; };
    tasks = final.tasks-qld;
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
    # mc-state-observation = prev.callPackage ./pkgs/mc-rtc/observers/mc-state-observation;
    mc-state-observation = prev.callPackage ./pkgs/mc-rtc/observers/mc-state-observation { };
    #lipm-walking-controller = prev.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
    # lipm-walking-controller = prev.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
    robogami-controller = prev.callPackage ./pkgs/mc-rtc/controllers/robogami-controller { };
    #mc-rtc-raylib = prev.callPackage ./pkgs/mc-rtc-raylib {};
    mc-rtc-msgs = prev.callPackage ./pkgs/mc-rtc-msgs { };
    mc-udp = prev.callPackage ./pkgs/mc-udp { };

    ## Robot description packages
    franka-description = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/franka-description.nix { };
    g1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/g1-description.nix { };
    h1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/h1-description.nix { };
    ur-description = prev.callPackage ./pkgs/mc-rtc/robots/descriptions/ur-description.nix { };
    ur5e-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/ur5e-description.nix { };
    human-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/human-description.nix { };
    jvrc-description = callWithRos ./pkgs/mc-rtc-data/jvrc-description.nix { };
    mc-env-description = callWithRos ./pkgs/mc-rtc-data/mc-env-description.nix { };
    mc-int-obj-description = callWithRos ./pkgs/mc-rtc-data/mc-int-obj-description.nix { };
    robogami-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/robogami-description.nix { };

    # Robot modules
    mc-g1 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-g1.nix { };
    mc-h1 = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-h1.nix { };
    mc-ur5e = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-ur5e.nix { };
    mc-human = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-human.nix { };
    mc-panda = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda { };
    mc-panda-lirmm = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-panda-lirmm.nix { };
    mc-robogami = prev.callPackage ./pkgs/mc-rtc/robots/modules/mc-robogami.nix { };

    libfranka_0_9_2 = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/libfranka.nix { };
    # mc-franka = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix {};
    mc-franka = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix { };
    mesh-sampling = prev.callPackage ./pkgs/mesh-sampling { };
    # mesh-sampling = prev.callPackage ./pkgs/mesh-sampling {};

    mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {
      with-python-bindings = with-python;
      with-python-tools = true;
      inherit qt;
    };
    mc-rtc-python-utils = prev.callPackage ./pkgs/mc-rtc/mc-rtc-python-utils.nix { };
    #mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {};
    # mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix { inherit useLocal; inherit localWorkspace; };
    mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix {
      inherit qt;
    };
    # mc-rtc-ticker = prev.callPackage ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
    mc-rtc-ticker = prev.callPackage ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix { };
    # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { with-ros = true; };
    # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { };
    # mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
    gram-savitzky-golay = prev.callPackage ./pkgs/gram-savitzky-golay { };

    ##########
    #  Apps  #
    ##########
    mujoco = prev.mujoco.overrideAttrs (old: {
      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ final.libGL ];
    });

    jvrc1-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/jvrc1-mj-description.nix { };
    g1-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/g1-mj-description.nix { };
    h1-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/h1-mj-description.nix { };
    ur5e-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/ur5e-mj-description.nix { };
    human-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/human-mj-description.nix { };

    env-mj-description = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/env-mj-description.nix { };

    # symlinkJoin all robots
    # FIXME: this triggers a full rebuild of mc-mujoco
    mc-mujoco = prev.callPackage ./pkgs/mc-rtc/mc-mujoco {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };

    mc-mujoco-robots = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix { };
    # mc-mujoco with all public robots
    mc-mujoco-robots-public = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
      robots = with final; [
        g1-mj-description
        h1-mj-description
        ur5e-mj-description
        human-mj-description
      ];
    };

    mc-mujoco-full = prev.callPackage ./pkgs/mc-rtc/mc-mujoco {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
      mc-mujoco-robots = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
        robots = final.mc-mujoco-robots-public.robots;
      };
    };

    ###############
    # CONTROLLERS #
    ###############
    panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis { };
    # panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis {};

    ###########
    # PLUGINS #
    ###########
    mc-force-shoe-plugin = prev.callPackage ./pkgs/mc-rtc/plugins/mc-force-shoe-plugin.nix { };
    mc-robot-model-update = prev.callPackage ./pkgs/mc-rtc/plugins/mc-robot-model-update.nix { };

    #############
    # 3rd-party #
    #############
    eigen-fmt = prev.callPackage ./pkgs/3rd-party/eigen-fmt {
      fmt = prev.fmt_10;
    };

    imguizmo = prev.callPackage ./pkgs/3rd-party/imguizmo.nix {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    corrade = prev.callPackage ./pkgs/3rd-party/magnum/corrade.nix { };
    magnum = prev.callPackage ./pkgs/3rd-party/magnum/magnum.nix { };
    magnum-integration = prev.callPackage ./pkgs/3rd-party/magnum/magnum-integration.nix {
      with-imguiintegration = true;
    };
    magnum-plugins = prev.callPackage ./pkgs/3rd-party/magnum/magnum-plugins.nix {
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

    sphinx-cmake = prev.callPackage ./pkgs/sphinx-cmake.nix { };

    ##########
    # TOOLS  #
    ##########
    mc-robot-tools = prev.callPackage ./pkgs/mc-rtc/tools/mc-robot-tools.nix { };

    ##########
    # PYTHON #
    ##########
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (
        python-final: _python-prev:
        {
          # custom overrides would go here see gepetto/nix for examples
        }
        // lib.filesystem.packagesFromDirectoryRecursive {
          inherit (python-final) callPackage;
          directory = ./py-pkgs;
        }
      )
    ];
  }
)
