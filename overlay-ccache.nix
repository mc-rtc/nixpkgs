{ }:

_final: prev:
let
  withCCache =
    packages:
    with builtins;
    listToAttrs (
      map (name: {
        inherit name;
        value =
          builtins.trace "overriding stdenv with ccacheStdenv for package ${name}"
            (getAttr name prev).override
            { stdenv = prev.ccacheStdenv; };
      }) packages
    );
  # usually this mean they don't have stdenv as an agument
  # if they are built with buildRosPackages they will use ccache anyways
  # XXX: Can we automate this?
  skipCcahePackages = [
    "mc-rtc-msgs"
    "magnum-with-plugins"
  ];
  allPackages = [
    "nanomsg"
    "eigen3-to-python"
    "spacevecalg"
    "rbdyn"
    "eigen-qld"
    "eigen-quadprog"
    "sch-core"
    "sch-core-python"
    "sch-visualization"
    "tasks-qld"
    "tasks"
    "mc-rtc-data"
    "state-observation"
    "mc-rbdyn-urdf"
    "tvm"
    "copra"
    "omniorb"
    "openrtm-aist"
    "openrtm-aist-python"
    "mc-state-observation"
    "lipm-walking-controller"
    "pendulum-feasibility-solver"
    "footsteps-planner-plugin"
    "mc-joystick-plugin"
    "ismpc-walking-controller"
    "robogami-controller"
    "mc-udp"
    "franka-description"
    "g1-description"
    "h1-description"
    "ur-description"
    "ur5e-description"
    "human-description"
    "jvrc-description"
    "mc-env-description"
    "mc-int-obj-description"
    "robogami-description"
    "pepper-description"
    "mc-g1"
    "mc-h1"
    "mc-ur5e"
    "mc-human"
    "mc-panda"
    "mc-panda-lirmm"
    "mc-robogami"
    "mc-pepper"
    "libfranka_0_9_2"
    "mc-franka"
    "mesh-sampling"
    "mc-rtc"
    "mc-rtc-ros-compat"
    "mc-rtc-python-utils"
    "mc-rtc-rviz-panel"
    "mc-rtc-ticker"
    "gram-savitzky-golay"
    "mujoco"
    "jvrc1-mj-description"
    "g1-mj-description"
    "h1-mj-description"
    "ur5e-mj-description"
    "human-mj-description"
    "env-mj-description"
    "mc-mujoco"
    "mc-mujoco-robots"
    "mc-mujoco-robots-public"
    "mc-mujoco-full"
    "panda-prosthesis"
    "mc-force-shoe-plugin"
    "mc-robot-model-update"
    "eigen-fmt"
    "imguizmo"
    "corrade"
    "magnum"
    "magnum-integration"
    "magnum-plugins"
    "magnum-with-plugins"
    "mc-rtc-imgui"
    "mc-rtc-magnum"
    "sphinx-cmake"
    "mc-robot-tools"
  ];
  ccachePackages = builtins.filter (name: !(builtins.elem name skipCcahePackages)) allPackages;
in
{
  ccacheWrapper = prev.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR="/var/cache/ccache"
      export CCACHE_UMASK=007
      # export CCACHE_SLOPPINESS=random_seed
      export CCACHE_SLOPPINESS=time_macros,include_file_mtime,file_macro,locale,pch_defines,random_seed
      # - `time_macros`: Ignore changes in __DATE__ and __TIME__ macros.
      # - `include_file_mtime`: Ignore changes in the mtime of included files.
      # - `file_macro`: Ignore changes in the __FILE__ macro.
      # - `locale`: Ignore locale differences.
      # - `pch_defines`: Ignore differences in precompiled header defines.
      # - mandatory: `random_seed`: Ignore random seed differences (already in your config).
      if [ ! -d "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' does not exist"
        echo "Please create it with:"
        echo "  sudo mkdir -m0770 -p '$CCACHE_DIR'"
        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
        echo ""
        echo "You should also add the path to the derivation sandbox by adding extra-sandbox-paths to nix.conf"
        echo "  echo 'extra-sandbox-paths = /var/cache/ccache' >> ~/.config/nix/nix.conf"
        echo "  sudo systemctl restart nix-daemon.service"
        echo "====="
      fi
      if [ ! -w "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
        echo "Please verify its access permissions"
        echo "====="
      fi
    '';
  };
}
// withCCache [ "buildRosPackage" ]
// withCCache ccachePackages
