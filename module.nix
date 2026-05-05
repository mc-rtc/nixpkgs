{
  lib,
  gepetto,
  jrl-cmakemodulesv2,
  enablePrivateOverlay ? false,
  enableCcacheOverlay ? false,
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
      null;

  ccacheOverlay =
    if enableCcacheOverlay then
      builtins.trace "mc-rtc-nix: importing ccache overlay" (
        final: prev: import ./overlay-ccache.nix { } final prev
      )
    else
      null;

  overlaysList = [
    (builtins.trace "mc-rtc-nix: importing overlay mc-rtc-pkgs" self.overlays.mc-rtc-pkgs)
  ]
  ++ (lib.optional enablePrivateOverlay (
    builtins.trace "mc-rtc-nix: importing overlay mc-rtc-private (enablePrivateOverlay: ${lib.boolToString enablePrivateOverlay})" self.overlays.mc-rtc-private
  ))
  ++ [
    (builtins.trace "mc-rtc-nix: importing overlay for jrl-cmakemodulesv2" (
      _final: prev: { jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default; }
    ))
  ]
  ++ (lib.optional enableCcacheOverlay (
    builtins.trace "mc-rtc-nix: importing overlay ccache (enableCcacheOverlay: ${lib.boolToString enableCcacheOverlay})" self.overlays.mc-rtc-ccache
  ));

  flakeOverlays = {
    mc-rtc-pkgs = import ./overlay.nix (
      builtins.trace "mc-rtc-nix: importing public overlay (with-ros: ${lib.boolToString with-ros})" {
        inherit with-ros;
      }
    );
  }
  // lib.optionalAttrs enablePrivateOverlay {
    mc-rtc-private = privateOverlay;
  }
  // lib.optionalAttrs enableCcacheOverlay {
    mc-rtc-ccache = ccacheOverlay;
  };
in
{
  imports = [ (builtins.trace "mc-rtc-nix: importing gepetto's flake module" gepetto.flakeModule) ];

  config = {
    flake.overlays = flakeOverlays;
    flakoboros.overlays = overlaysList;
    flakoboros.nixpkgsConfig = {
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };
}
