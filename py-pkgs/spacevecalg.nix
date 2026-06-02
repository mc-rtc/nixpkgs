{
  toPythonModule,
  pkgs,
}:
toPythonModule (
  pkgs.spacevecalg.override {
    inherit (pkgs) python3Packages;
  }
)
