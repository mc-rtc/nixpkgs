/**
- **`final`**: The package set after all overlays have been applied.
  Use this if you want to reference packages as they will appear after your overlay and others are merged.

- **`prev`**: The package set before your overlay is applied (i.e., the "previous" state).
  Use this to access and override existing packages, or to call functions from the underlying package set.
*/
{ useLocal ? false, localWorkspace ? null, with-ros ? false, ... }:
(final: prev:
let
  callWithLocal = pkg: { ... }@args:
    prev.callPackage pkg ({
      inherit useLocal localWorkspace;
    } // args);
  callWithRos = pkg: args: prev.callPackage pkg (args // { inherit with-ros; });
  callWithRosLocal = pkg: args: prev.callPackage pkg (args // { inherit with-ros useLocal localWorkspace; });
in rec
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
    xacro;

  nanomsg = prev.nanomsg.overrideAttrs (old: rec {
    postPatch = ''
      substituteInPlace cmake/nanomsg-config.cmake.in \
        --replace '@PACKAGE_CMAKE_INSTALL_PREFIX@/' ""
    '';
  });

  spacevecalg = prev.callPackage ./pkgs/spacevecalg {};
  rbdyn = prev.callPackage ./pkgs/rbdyn {};
  eigen-qld = prev.callPackage ./pkgs/eigen-qld {};
  eigen-quadprog = prev.callPackage ./pkgs/eigen-quadprog {};
  sch-core = prev.callPackage ./pkgs/sch-core {};
  #sch-visualization = prev.callPackage ./pkgs/sch-visualization {};
  sch-visualization = callWithLocal ./pkgs/sch-visualization {};
  tasks = prev.callPackage ./pkgs/tasks {};
  mc-env-description = callWithRos ./pkgs/mc-rtc-data/mc-env-description.nix {};
  mc-int-obj-description = callWithRos ./pkgs/mc-rtc-data/mc-int-obj-description.nix {};
  jvrc-description = callWithRos ./pkgs/mc-rtc-data/jvrc-description.nix {};
  # mc-rtc-data = prev.callPackage ./pkgs/mc-rtc-data { with-ros = false; };
  mc-rtc-data = callWithRos ./pkgs/mc-rtc-data {};
  state-observation = prev.callPackage ./pkgs/state-observation {};
  mc-rbdyn-urdf = prev.callPackage ./pkgs/mc-rbdyn-urdf {};
  tvm = prev.callPackage ./pkgs/tvm {};
  copra = prev.callPackage ./pkgs/copra {};
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
  openrtm-aist = prev.callPackage ./pkgs/openrtm-aist {};
  openrtm-aist-python = prev.callPackage ./pkgs/openrtm-aist-python {
    buildPythonPackage = prev.python2Packages.buildPythonPackage;
  };
  # mc-state-observation = callWithLocal ./pkgs/mc-rtc/observers/mc-state-observation;
  mc-state-observation = prev.callPackage ./pkgs/mc-rtc/observers/mc-state-observation {};
  #lipm-walking-controller = prev.callPackage ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
  # lipm-walking-controller = callWithLocal ./pkgs/mc-rtc/controllers/lipm-walking-controller {};
  #mc-rtc-raylib = prev.callPackage ./pkgs/mc-rtc-raylib {};
  mc-rtc-msgs = prev.callPackage ./pkgs/mc-rtc-msgs {};
  mc-udp = prev.callPackage ./pkgs/mc-udp {};
  hrp4-description = callWithRos ./pkgs/mc-rtc/robots/hrp4-description {};
  mc-hrp4 = prev.callPackage ./pkgs/mc-rtc/robots/mc-hrp4 {};
  hrp2-description = callWithRos ./pkgs/hrp2-description {};
  mc-hrp2 = prev.callPackage ./pkgs/mc-rtc/robots/mc-hrp2 { };
  hrp5-p-description = callWithRos ./pkgs/mc-rtc/robots/hrp5-p-description {};
  mc-hrp5-p = prev.callPackage ./pkgs/mc-rtc/robots/mc-hrp5-p {};
  mc-rhps1 = prev.callPackage ./pkgs/mc-rtc/robots/mc-rhps1 {};
  rhps1-description = callWithRosLocal ./pkgs/mc-rtc/robots/rhps1-description {};
  libfranka = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/libfranka.nix {};
  mc-panda = callWithRos ./pkgs/mc-rtc/robots/mc-panda {};
  mc-panda-lirmm = callWithLocal ./pkgs/mc-rtc/robots/mc-panda/mc-panda-lirmm.nix {};
  # mc-franka = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix {};
  mc-franka = callWithLocal ./pkgs/mc-rtc/robots/mc-panda/mc-franka.nix {};
  franka-description = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/franka-description.nix {};
  poco = prev.callPackage ./pkgs/mc-rtc/robots/mc-panda/libpoco.nix {};
  mesh-sampling = prev.callPackage ./pkgs/mesh-sampling {};
  # mesh-sampling = callWithLocal ./pkgs/mesh-sampling {};
  mc-rtc = callWithRosLocal ./pkgs/mc-rtc/mc-rtc.nix {};
  mc-rtc-python-utils = callWithLocal ./pkgs/mc-rtc/mc-rtc-python-utils.nix {};
  #mc-rtc = callWithRos ./pkgs/mc-rtc/mc-rtc.nix {};
  # mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix { inherit useLocal; inherit localWorkspace; };
  mc-rtc-rviz-panel = prev.libsForQt5.callPackage ./pkgs/mc-rtc/ros/mc-rtc-rviz-panel.nix {};
  # mc-rtc-ticker = callWithLocal ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
  mc-rtc-ticker = prev.callPackage ./pkgs/mc-rtc/ros/mc-rtc-ticker.nix {};
  # mc-rtc = callWithLocal ./pkgs/mc-rtc/mc-rtc.nix { with-ros = true; };
  # mc-rtc = prev.callPackage ./pkgs/mc-rtc/mc-rtc.nix { };
  # mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};
  gram-savitzky-golay = prev.callPackage ./pkgs/gram-savitzky-golay {};

  ######################
  # Overrides for hugo #
  # polytopeController #
  ######################
  mc-rtc-hugo = final.mc-rtc.overrideAttrs (old: {
    tvm = final.tvm-hugo;
    src = final.fetchgit {
      url = "https://github.com/arntanguy/mc_rtc.git";
      rev = "73b10e8d7db6671e901d16f6ec9cde299c07ba4d";
      sha256 = "sha256-MJrulDf6Qm8esLLJxIZoLerG3p/ug5M9WnMYoonHtrw=";
    };
    pname = "mc-rtc-hugo";
  });

  tvm-hugo = final.tvm.overrideAttrs (old: {
    src = final.fetchgit {
      # tvm pr 53
      url = "https://github.com/Hugo-L3174/tvm.git";
      rev = "0c66fac37db38f2e5bc4f3df2b418f3ae50cea68";
      sha256 = "sha256-wLalEmtXO4Id8PFtVoJD9KzCU4QKeAv/xp5mCjDvpnA=";
    };
  });
  mc-rtc-magnum-hugo = final.mc-rtc-magnum.overrideAttrs (old: {
    mc-rtc = final.mc-rtc-hugo;
  });
  mc-mujoco-hugo = final.mc-mujoco.overrideAttrs (old: {
    mc-rtc = final.mc-rtc-hugo;
  });
  mc-force-shoe-plugin-hugo = final.mc-force-shoe-plugin.overrideAttrs (old: {
    mc-rtc = final.mc-rtc-hugo;
  });
  polytopeController = callWithLocal ./pkgs/mc-rtc/controllers/polytopeController {};
  #mc-dynamic-polytopes = prev.callPackage ./pkgs/mc-rtc/controllers/polytopeController/mc-dynamic-polytopes.nix {};
  mc-dynamic-polytopes = callWithLocal ./pkgs/mc-rtc/controllers/polytopeController/mc-dynamic-polytopes.nix {
    jrl-cmakemodules = final.jrl-cmakemodulesv2;
    mc-rtc = final.mc-rtc-hugo;
  };
  dcm-vrptask = callWithLocal ./pkgs/mc-rtc/controllers/polytopeController/dcm-vrptask.nix {
    mc-rtc = final.mc-rtc-hugo;
    jrl-cmakemodules = final.jrl-cmakemodulesv2;
  };

  ##########
  #  Apps  #
  ##########
  mujoco = prev.mujoco.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ final.libGL ];
  });
  #mc-mujoco = prev.callPackage ./pkgs/mc-rtc/mc-mujoco.nix {};

  jvrc1-mj-description = callWithLocal ./pkgs/mc-rtc/mc-mujoco/robots/jvrc1-mj-description.nix {};
  env-mj-description = callWithLocal ./pkgs/mc-rtc/mc-mujoco/robots/env-mj-description.nix {};
  # symlinkJoin all robots
  mc-mujoco-robots = prev.callPackage ./pkgs/mc-rtc/mc-mujoco/robots/default.nix {
    # robots = [...];
  };
  mc-mujoco = callWithLocal ./pkgs/mc-rtc/mc-mujoco {
    jrl-cmakemodules = final.jrl-cmakemodulesv2;
  };

  ###############
  # CONTROLLERS #
  ###############
  panda-prosthesis = callWithLocal ./pkgs/mc-rtc/controllers/panda-prosthesis {};
  # panda-prosthesis = prev.callPackage ./pkgs/mc-rtc/controllers/panda-prosthesis {};

  ###########
  # PLUGINS #
  ###########
  mc-force-shoe-plugin = callWithLocal ./pkgs/mc-rtc/plugins/mc-force-shoe-plugin.nix {};
  mc-robot-model-update = callWithLocal ./pkgs/mc-rtc/plugins/mc-robot-model-update.nix {};

  #############
  # 3rd-party #
  #############
  eigen-fmt = prev.callPackage ./pkgs/3rd-party/eigen-fmt {};
  politopix = prev.callPackage ./pkgs/3rd-party/politopix.nix {
    fetchurl = final.stdenv.fetchurlBoot;
  };

  imguizmo = callWithLocal ./pkgs/3rd-party/imguizmo.nix {
    jrl-cmakemodules = final.jrl-cmakemodulesv2;
  };
  corrade = prev.callPackage ./pkgs/3rd-party/magnum/corrade.nix {};
  magnum = prev.callPackage ./pkgs/3rd-party/magnum/magnum.nix {};
  magnum-integration = callWithLocal ./pkgs/3rd-party/magnum/magnum-integration.nix {
    with-imguiintegration = true;
  };
  magnum-plugins = callWithLocal ./pkgs/3rd-party/magnum/magnum-plugins.nix {
    magnumPluginsWithAssimpImporter = true;
    magnumPluginsWithStbImageImporter = true;
  };
  magnum-with-plugins = prev.callPackage ./pkgs/3rd-party/magnum/magnum-with-plugins.nix {};
  mc-rtc-imgui = callWithLocal ./pkgs/mc-rtc-imgui {
    jrl-cmakemodules = final.jrl-cmakemodulesv2;
  };
  # standlone version of mc-rtc-magnum, with independent packaging for magnum and its plugins
  # and a standalone mc-rtc-imgui version
  # This should ultimately replace mc-rtc-magnum when all issues have been resolved
  mc-rtc-magnum-standalone = callWithLocal ./pkgs/mc-rtc-magnum/standalone.nix {};
  mc-rtc-magnum = final.mc-rtc-magnum-standalone;
  # for the non standalone version of mc_rtc-magnum to be removed after further testing
  # mc-rtc-magnum = callWithLocal ./pkgs/mc-rtc-magnum {};
  # mc-rtc-magnum = prev.callPackage ./pkgs/mc-rtc-magnum {};

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

  # default superbuild environment
  mc-rtc-superbuild = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix { 
    apps = [ mc-rtc-magnum mc-mujoco mc-rtc-ticker ];
  };

  mc-rtc-superbuild-standalone-magnum = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix { 
    apps = [ mc-rtc-magnum-standalone ];
  };

  mc-rtc-superbuild-rolkneematics = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix { 
    robots = [
      # note that panda-prosthesis is not strictly-speaking a robot, but it builds a robot module so we need it here as well to populate the robots runtime paths
      panda-prosthesis
      mc-panda-lirmm
      mc-panda
    ];
    controllers = [ panda-prosthesis ];
    # extra mc_rtc.yaml
    configs = [ "${panda-prosthesis}/lib/mc_controller/etc/mc_rtc.yaml" ];
    observers = [];
    plugins = [ panda-prosthesis mc-force-shoe-plugin ];
    apps = [ mc-rtc-magnum mc-franka mc-rtc-ticker sch-visualization ];
  };

  mc-rtc-superbuild-hugo = prev.callPackage ./pkgs/mc-rtc/mc-rtc-superbuild-standalone.nix { 
    robots = [ mc-rhps1 ];
    # observers = [mc-state-observation]; # FIXME missing Attitude observer from mc_state_observation
    controllers = [polytopeController];
    configs = [ "${polytopeController}/lib/mc_controller/etc/mc_rtc.yaml" ];
    Enabled = "CoM";
    MainRobot = "JVRC1";
    # plugins = [ mc-force-shoe-plugin-hugo ];
    #apps = [ mc-rtc-magnum-hugo mujoco ]; #mc-mujoco-hugo ];
    #apps = [ mujoco mc-mujoco-hugo ];
    #apps = [ magnum-with-plugins ];
    apps = [ mc-rtc-magnum-hugo ];
    # apps = [ mc-mujoco-hugo ];
  };

})
