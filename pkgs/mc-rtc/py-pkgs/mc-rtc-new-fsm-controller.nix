{
  buildPythonPackage,
  setuptools,
  wheel,
  gitpython,
  mc-rtc,
  mc-rtc-new-controller,
}:
buildPythonPackage {
  pname = "mc-rtc-new-fsm-controller";
  version = "0.1.0";
  pyproject = true;

  src = builtins.path {
    path = "${mc-rtc.fullSrc}/utils/python/mc_rtc_new_fsm_controller";
    name = "mc_rtc_new_fsm_controller";
  };

  build-system = [
    setuptools
    wheel
  ];
  propagatedBuildInputs = [
    mc-rtc-new-controller
    gitpython
  ];
}
