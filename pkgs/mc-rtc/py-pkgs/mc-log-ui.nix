{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
  pyqt5,
  numpy,
  matplotlib,
  qt5,
  mc-rtc,
  with-mc-rtc ? true,
}:
let
  common = import ../mc-rtc-common.nix {
    inherit fetchFromGitHub;
  };
in
buildPythonPackage {
  pname = "mc_log_ui";
  version = "1.0.0";
  pyproject = true;
  # without this it tries to use cmake when including mc-rtc, why?
  dontConfigure = true;

  src = "${common.src}/utils/python/mc_log_ui";

  build-system = [ setuptools ];
  propagatedBuildInputs = [
    pyqt5
    numpy
    matplotlib
  ]
  ++ (lib.optional with-mc-rtc mc-rtc);

  postFixup = ''
    wrapProgram $out/bin/mc_log_ui \
      --set PYTHONPATH "$out/${python.sitePackages}:$PYTHONPATH" \
      --set QT_PLUGIN_PATH "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}"
    wrapProgram $out/bin/plot_logs \
      --set PYTHONPATH "$out/${python.sitePackages}:$PYTHONPATH" \
      --set QT_PLUGIN_PATH "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}"
  '';
}
