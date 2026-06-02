{
  toPythonModule,
  pkgs,
}:
toPythonModule (
  pkgs.sch-core-python.override {
    inherit (pkgs) python3Packages;
  }
)
