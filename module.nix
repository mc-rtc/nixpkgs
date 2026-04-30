{
  lib,
  gepetto,
  jrl-cmakemodulesv2,
  enablePrivateOverlay ? false,
  with-ros ? true,
  ...
}:
{
  self,
  ...
}:
let
  privateOverlay =
    if enablePrivateOverlay then
      builtins.trace "mc-rtc-nix: importing private overlay (with-ros: ${lib.boolToString with-ros})" (
        final: prev: import ./overlay-private.nix { inherit with-ros; } final prev
      )
    else
      builtins.trace
        "mc-rtc-nix: private overlay is disabled, using an empty overlay (enablePrivateOverlay: ${lib.boolToString enablePrivateOverlay})"
        (_: _: { });
in
{
  imports = [ (builtins.trace "mc-rtc-nix: importing gepetto's flake module" gepetto.flakeModule) ];

  config = {
    flake.overlays.mc-rtc-pkgs = import ./overlay.nix (
      builtins.trace "mc-rtc-nix: importing public overlay (with-ros: ${lib.boolToString with-ros})" {
        inherit with-ros;
      }
    );
    flake.overlays.mc-rtc-private = privateOverlay;
    flakoboros.overlays = [
      (builtins.trace "mc-rtc-nix: importing overlay mc-rtc-pkgs" self.overlays.mc-rtc-pkgs)
      (builtins.trace "mc-rtc-nix: importing overlay mc-rtc-private (enablePrivateOverlay: ${lib.boolToString enablePrivateOverlay})" self.overlays.mc-rtc-private)
      (builtins.trace "mc-rtc-nix: importing overlay for jrl-cmakemodulesv2" (
        _final: prev: { jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default; }
      ))
    ];
    # Set permittedInsecurePackages for all pkgs instances
    flakoboros.nixpkgsConfig = {
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };
}
