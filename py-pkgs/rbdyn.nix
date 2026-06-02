{
  toPythonModule,
  pkgs,
}:
toPythonModule (
  pkgs.rbdyn.override {
    inherit (pkgs) python3Packages;
  }
)
