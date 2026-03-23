{ pkgs }:

let
  enabled = "CoM";
  main_robot = "JVRC1";

  mc-rtc = pkgs.mc-rtc.override {
    with-ros = false;
    # These are the package that will be added to your mc_rtc base installation
    # The default configuration (JVRC1 robot and CoM controller) requires no extras
    #
    # - Example: bring in HRP2/HRP4/HRP5P/panda
    #          (requires access rights and a correctly configured ssh key for HRP robots)
    #   extensions = with pkgs; [ mc-hrp2 mc-hrp4 mc-hrp5-p mc-panda mc-state-observation ];
    # - Example: bring in lipm-walking-controller which requires mc-state-observation
    #   extensions = with pkgs; [ lipm-walking-controller mc-state-observation ];
    extensions = with pkgs; [ mc-state-observation ];
  };

  # Here we define a local controller that will be built within the local environment
  # my-controller = { cmake, mc-rtc }: pkgs.stdenv.mkDerivation {
  #   pname = "my-controller";
  #   version = "1.0.0";
  #
  #   # Shows how the source folder can be changed for mc_rtc 2.0.0 adaptation
  #   src = if mc-rtc.with-tvm then
  #       /home/gergondet/devel/src/my_controller
  #     else
  #       /home/gergondet/devel/src/my_controller;
  #
  #   nativeBuildInputs = [ cmake ];
  #   buildInputs = [ mc-rtc ];
  #
  #   cmakeFlags = [
  #     "-DBUILD_TESTING=OFF"
  #     "-DPYTHON_BINDING=OFF"
  #     "-DINSTALL_DOCUMENTATION=OFF"
  #   ];
  #
  #   doCheck = false;
  # };

  observer_module_paths = [ "${mc-rtc}/lib/mc_observers" ];
  robot_module_paths = [ "${mc-rtc}/lib/mc_robots" ];
  controller_module_paths = [ "${mc-rtc}/lib/mc_controller" ];
  global_plugin_paths = [ "${mc-rtc}/lib/mc_plugins" ];
 
  mc_rtc_yaml = pkgs.writeTextFile {
    name = "mc_rtc.yaml";
    text = ''
      Enabled: ["${enabled}"]
      MainRobot: "${main_robot}"

      ObserverPipelines:
        name: "Test mc-state-observation"
        observers:
          - type: Encoder
          - type: Attitude 

      ClearObserverModulePath: true
      ObserverModulePaths: [${builtins.concatStringsSep "," (map (p: "\"${p}\"") observer_module_paths)}]

      ClearRobotModulePath: true
      RobotModulePaths: [${builtins.concatStringsSep "," (map (p: "\"${p}\"") robot_module_paths)}]

      ClearControllerModulePath: true
      ControllerModulePaths: [${builtins.concatStringsSep "," (map (p: "\"${p}\"") controller_module_paths)}]

      ClearGlobalPluginPath: true
      GlobalPluginPaths: [${builtins.concatStringsSep "," (map (p: "\"${p}\"") global_plugin_paths)}]
    '';
  };
in

pkgs.mkShell {
  buildInputs = [ mc-rtc pkgs.clang-tools ];
  shellHook = ''
    export TMP=/tmp
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TEMPDIR=/tmp
    etc_dir=$(cd etc && pwd)
    tmp_dir=$(mktemp -d /tmp/mc-rtc-nix.XXXXXXXXXXXX)
    cleanup_build() {
      cd $HOME
      rm -rf $tmp_dir
      return 0
    }
    cleanup_and_exit() {
      cleanup_build
      exit
    }
    trap cleanup_build EXIT
    trap cleanup_and_exit SIGINT
    cd $tmp_dir
    echo "==== Running with mc_rtc.yaml configuration: ===="
    echo "mc_rtc.yaml path: ${mc_rtc_yaml}"
    cat ${mc_rtc_yaml}
    echo "===================="
    mc_rtc_ticker -f ${mc_rtc_yaml} 
    exit
  '';
}

