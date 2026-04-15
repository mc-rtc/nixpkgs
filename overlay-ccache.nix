{ }:

_final: prev:
let
  withCCache =
    packages:
    with builtins;
    listToAttrs (
      map (name: {
        inherit name;
        value = (getAttr name prev).override { stdenv = prev.ccacheStdenv; };
      }) packages
    );
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
        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
        echo "====="
        exit 1
      fi
      if [ ! -w "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
        echo "Please verify its access permissions"
        echo "====="
        exit 1
      fi
    '';
  };
}
// withCCache [
  "spacevecalg"
  "rbdyn"
  "sch-core"
  "eigen-qld"
  "eigen-quadprog"
  "tasks"
  "tvm"
  "mc-rtc-magnum"
  "mc-rtc-magnum-standalone"
  "mc-panda"
  "mc-panda-lirmm"
  "libpoco"
  "libfranka"
  "mc-franka"
  "panda-prosthesis"

  "mc-force-shoe-plugin"

  "magnum"
  "magnum-integration"
  "magnum-plugins"
  "mc_rtc-imgui"

  # "mc-rtc-rviz-panel" # how to make it work for buildRosPackage?
  # "mc-rtc"
]
