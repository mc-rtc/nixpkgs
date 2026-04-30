{
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
      builtins.trace "Enabling private overlay" (
        final: prev: import ./overlay-private.nix { inherit with-ros; } final prev
      )
    else
      (_: _: { });
in
{
  imports = [ gepetto.flakeModule ];

  config = {
    flake.overlays.mc-rtc-pkgs = import ./overlay.nix {
      inherit with-ros;
    };
    flake.overlays.mc-rtc-private = privateOverlay;
    flakoboros.overlays = [
      self.overlays.mc-rtc-pkgs
      self.overlays.mc-rtc-private
      (_final: prev: { jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default; })
    ];
    # Set permittedInsecurePackages for all pkgs instances
    flakoboros.nixpkgsConfig = {
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };
}
