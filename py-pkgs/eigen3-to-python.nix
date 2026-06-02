{
  toPythonModule,
  pkgs,
}:
toPythonModule (
  pkgs.eigen3-to-python.override {
    inherit (pkgs) python3Packages;
  }
)
