{
  lib,
  buildPythonPackage,
  python,
  fetchFromGitHub,
  setuptools,
  pyqt5,
  numpy,
  matplotlib,
  qt,
  mc-rtc,
  with-mc-rtc ? true,
}:
buildPythonPackage {
  pname = "mc_log_ui";
  version = "1.0.0";
  pyproject = true;
  # without this it tries to use cmake when including mc-rtc, why?
  dontConfigure = true;

  src = fetchFromGitHub {
    owner = "mc-rtc";
    repo = "mc_log_ui";
    rev = "95364d49c9b36aec59cd1a8e4cc857287af9108b";
    hash = "sha256-4F55vii6g93cVhkIbesQEL93rUKSordZmNzntw+22uo=";
  };

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
      --set QT_PLUGIN_PATH "${qt.qtbase}/${qt.qtbase.qtPluginPrefix}"
    wrapProgram $out/bin/plot_logs \
      --set PYTHONPATH "$out/${python.sitePackages}:$PYTHONPATH" \
      --set QT_PLUGIN_PATH "${qt.qtbase}/${qt.qtbase.qtPluginPrefix}"
  '';
}
