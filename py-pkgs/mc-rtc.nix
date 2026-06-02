{
  toPythonModule,
  pkgs,
}:
toPythonModule (
  pkgs.mc-rtc.override {
    inherit (pkgs) python3Packages;
  }
)
