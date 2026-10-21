{
  buildPythonPackage,
  setuptools,
  wheel,
  gitpython,
  mc-rtc,
}:
buildPythonPackage {
  pname = "mc-rtc-new-controller";
  version = "0.1.0";
  pyproject = true;

  src = builtins.path {
    path = "${mc-rtc.fullSrc}/utils/python/mc_rtc_new_controller";
    name = "mc_rtc_new_controller";
  };

  build-system = [
    setuptools
    wheel
  ];
  propagatedBuildInputs = [ gitpython ];
}
