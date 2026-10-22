{
  buildPythonPackage,
  python,
  setuptools,
  build,
  pyqt5,
  numpy,
  matplotlib,
  qt5,
  mc-rtc,
  with-mc-rtc ? true,
  fetchFromGitHub,
  lib,
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
    rev = "3675017b00650f0eb03ffcc8dc938a43a8ab2670";
    hash = "sha256-A+eHuliV2O5YUEOV4UbSbzuPUKDdu10qvX4w036FSWY=";
  };

  build-system = [
    setuptools
    build
  ];
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
