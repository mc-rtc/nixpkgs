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
    callWithRos = pkg: args: final.callPackage pkg (args // { inherit with-ros; });
  in
  {
    # FIXME ros version
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

    mkMcRtcController = final.callPackage ./pkgs/mc-rtc/mk-mc-rtc-controller.nix { };

    nanomsg = prev.nanomsg.overrideAttrs (_old: rec {
      postPatch = ''
        substituteInPlace cmake/nanomsg-config.cmake.in \
          --replace '@PACKAGE_CMAKE_INSTALL_PREFIX@/' ""
      '';
    });

    eigen3-to-python = final.callPackage ./pkgs/eigen3-to-python { };
    spacevecalg = final.callPackage ./pkgs/spacevecalg { inherit with-python; };
    rbdyn = final.callPackage ./pkgs/rbdyn { inherit with-python; };
    eigen-qld = final.callPackage ./pkgs/eigen-qld { };
    eigen-quadprog = final.callPackage ./pkgs/eigen-quadprog { };
    sch-core = final.callPackage ./pkgs/sch-core { };
    sch-core-python = final.callPackage ./pkgs/sch-core-python { };
    #sch-visualization = final.callPackage ./pkgs/sch-visualization {};
    sch-visualization = final.callPackage ./pkgs/sch-visualization { };
    tasks-qld = final.callPackage ./pkgs/tasks { inherit with-python; };
    tasks = final.tasks-qld;
    # mc-rtc-data = final.callPackage ./pkgs/mc-rtc-data { with-ros = false; };
    mc-rtc-data = callWithRos ./pkgs/mc-rtc-data { };
    state-observation = final.callPackage ./pkgs/state-observation { };
    mc-rbdyn-urdf = final.callPackage ./pkgs/mc-rbdyn-urdf { };
    tvm = final.callPackage ./pkgs/tvm { };
    copra = final.callPackage ./pkgs/copra { };
    omniorb = prev.symlinkJoin {
      name = "omniorb";
      paths = [
        prev.omniorb.out
        (final.callPackage ./pkgs/omniorb-python {
          omniorb = prev.omniorb;
          buildPythonPackage = prev.python2Packages.buildPythonPackage;
        }).out
      ];
    };
    openrtm-aist = final.callPackage ./pkgs/openrtm-aist { };
    openrtm-aist-python = final.callPackage ./pkgs/openrtm-aist-python {
      buildPythonPackage = prev.python2Packages.buildPythonPackage;
    };
    # mc-state-observation = final.callPackage ./pkgs/mc-rtc/observers/mc-state-observation;
    mc-state-observation = final.callPackage ./pkgs/mc-rtc/observers/mc-state-observation { };
    lipm-walking-controller = final.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller { };
    pendulum-feasibility-solver =
      final.callPackage ./pkgs/mc-rtc/controllers/ismpc-walking/pendulum-feasibility-solver.nix
        { };
    footsteps-planner-plugin =
      final.callPackage ./pkgs/mc-rtc/controllers/ismpc-walking/footsteps-planner-plugin.nix
        { };
    mc-joystick-plugin =
      final.callPackage ./pkgs/mc-rtc/controllers/ismpc-walking/mc-joystick-plugin.nix
        { };
    ismpc-walking-controller =
      final.callPackage ./pkgs/mc-rtc/controllers/ismpc-walking/ismpc-walking-controller.nix
        { };
    robogami-controller = final.callPackage ./pkgs/mc-rtc/controllers/robogami-controller { };
    #mc-rtc-raylib = final.callPackage ./pkgs/mc-rtc-raylib {};
    mc-rtc-msgs = final.callPackage ./pkgs/mc-rtc-msgs { };
    mc-udp = final.callPackage ./pkgs/mc-udp { };

    ## Robot description packages
    franka-description = final.callPackage ./pkgs/mc-rtc/robots/mc-panda/franka-description.nix { };
    g1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/g1-description.nix { };
    h1-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/h1-description.nix { };
    ur-description = final.callPackage ./pkgs/mc-rtc/robots/descriptions/ur-description.nix { };
    ur5e-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/ur5e-description.nix { };
    human-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/human-description.nix { };
    jvrc-description = callWithRos ./pkgs/mc-rtc-data/jvrc-description.nix { };
    mc-env-description = callWithRos ./pkgs/mc-rtc-data/mc-env-description.nix { };
    mc-int-obj-description = callWithRos ./pkgs/mc-rtc-data/mc-int-obj-description.nix { };
    robogami-description = callWithRos ./pkgs/mc-rtc/robots/descriptions/robogami-description.nix { };
    pepper-description = callWithRos ./pkgs/mc-rtc/robots/mc-pepper/pepper-description.nix { };

    # Robot modules
    mc-g1 = final.callPackage ./pkgs/mc-rtc/robots/modules/mc-g1.nix { };
    mc-h1 = final.callPackage ./pkgs/mc-rtc/robots/modules/mc-h1.nix { };
    mc-ur5e = final.callPackage ./pkgs/mc-rtc/robots/modules/mc-ur5e.nix { };
    mc-human = final.callPackage ./pkgs/mc-rtc/robots/modules/mc-human.nix { };
    mc-panda = final.callPackage ./pkgs/mc-rtc/robots/mc-panda { };
    mc-panda-lirmm = final.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-panda-lirmm.nix { };
    mc-robogami = final.callPackage ./pkgs/mc-rtc/robots/modules/mc-robogami.nix { };
    mc-pepper = final.callPackage ./pkgs/mc-rtc/robots/mc-pepper/mc-pepper.nix { };

    libfranka_0_9_2 = final.callPackage ./pkgs/mc-rtc/robots/mc-panda/libfranka.nix { };
    # mc-franka = final.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix {};
    mc-franka = final.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix { };
    mesh-sampling = final.callPackage ./pkgs/mesh-sampling { };
    # mesh-sampling = final.callPackage ./pkgs/mesh-sampling {};

    mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {
      inherit with-ros;
      with-python-bindings = with-python;
      with-python-tools = true;
      inherit qt;
    };
    mc-rtc-ros-compat = callWithRos ./pkgs/mc-rtc/mc-rtc-ros-compat.nix {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    mc-rtc-python-utils = final.callPackage ./pkgs/mc-rtc/mc-rtc-python-utils.nix { };
    mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix {
      inherit qt;
    };
    mc-rtc-rviz = final.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz.nix { };
    mc-rtc-ticker = final.callPackage ./pkgs/mc-rtc/mc-rtc-ticker.nix { };
    gram-savitzky-golay = final.callPackage ./pkgs/gram-savitzky-golay { };

    ##########
    #  Apps  #
    ##########
    mujoco = prev.mujoco.overrideAttrs (old: {
      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ final.libGL ];
    });

    jvrc1-mj-description =
      final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/jvrc1-mj-description.nix
        { };
    g1-mj-description = final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/g1-mj-description.nix { };
    h1-mj-description = final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/h1-mj-description.nix { };
    ur5e-mj-description = final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/ur5e-mj-description.nix { };
    human-mj-description =
      final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/human-mj-description.nix
        { };

    env-mj-description = final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/env-mj-description.nix { };

    # symlinkJoin all robots
    # FIXME: this triggers a full rebuild of mc-mujoco
    mc-mujoco = final.callPackage ./pkgs/mc-rtc/mc-mujoco {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };

    mc-mujoco-robots = final.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix { };
    # mc-mujoco with all public robots
    mc-mujoco-robots-public = final.mc-mujoco-robots.override {
      robots = with final; [
        g1-mj-description
        h1-mj-description
        ur5e-mj-description
        human-mj-description
      ];
    };

    mc-mujoco-full = final.mc-mujoco.override {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
      mc-mujoco-robots = final.mc-mujoco-robots.override {
        robots = final.mc-mujoco-robots-public.robots;
      };
    };

    ###############
    # CONTROLLERS #
    ###############
    panda-prosthesis = final.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis { };

    ###########
    # PLUGINS #
    ###########
    mc-force-shoe-plugin = final.callPackage ./pkgs/mc-rtc/plugins/mc-force-shoe-plugin.nix { };
    mc-robot-model-update = final.callPackage ./pkgs/mc-rtc/plugins/mc-robot-model-update.nix { };

    #############
    # 3rd-party #
    #############
    eigen-fmt = final.callPackage ./pkgs/3rd-party/eigen-fmt {
      fmt = prev.fmt_10;
    };

    imguizmo = final.callPackage ./pkgs/3rd-party/imguizmo.nix {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    corrade = final.callPackage ./pkgs/3rd-party/magnum/corrade.nix { };
    magnum = final.callPackage ./pkgs/3rd-party/magnum/magnum.nix { };
    magnum-integration = final.callPackage ./pkgs/3rd-party/magnum/magnum-integration.nix {
      with-imguiintegration = true;
    };
    magnum-plugins = final.callPackage ./pkgs/3rd-party/magnum/magnum-plugins.nix {
      magnumPluginsWithAssimpImporter = true;
      magnumPluginsWithStbImageImporter = true;
    };
    magnum-with-plugins = final.callPackage ./pkgs/3rd-party/magnum/magnum-with-plugins.nix { };
    mc-rtc-imgui = final.callPackage ./pkgs/mc-rtc-imgui {
      jrl-cmakemodules = final.jrl-cmakemodulesv2;
    };
    # standlone version of mc-rtc-magnum, with independent packaging for magnum and its plugins
    # and a standalone mc-rtc-imgui version
    mc-rtc-magnum = final.callPackage ./pkgs/mc-rtc-magnum/standalone.nix { };

    sphinx-cmake = final.callPackage ./pkgs/sphinx-cmake.nix { };

    ##########
    # TOOLS  #
    ##########
    mc-robot-tools = final.callPackage ./pkgs/mc-rtc/tools/mc-robot-tools.nix { };

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
