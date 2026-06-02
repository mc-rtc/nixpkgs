{
  toPythonModule,
  pkgs,
}:
toPythonModule (
  pkgs.tasks.override {
    inherit (pkgs) python3Packages;
  }
)
