{
  gepetto,
  ...
}:
{
  lib,
  self,
  ...
}:
{
  imports = [ gepetto.flakeModule ];

  config = {
    flake.overlays.mc-rtc-pkgs = import ./overlay.nix { inherit lib; };
    flakoboros.overlays = [ self.overlays.mc-rtc-pkgs ];
  };
}
