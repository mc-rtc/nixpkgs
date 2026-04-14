{
  gepetto,
  jrl-cmakemodulesv2,
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
    flake.overlays.mc-rtc-pkgs = import ./overlay.nix 
    {
      inherit lib; inherit jrl-cmakemodulesv2; 
      with-ros = true;
      # FIXME: stop doing this and do proper flake.nix overrides in each package ;)
      useLocal = true;
      localWorkspace = "/home/arnaud/devel/mc-rtc-nix/workspace";
    };
    flakoboros.overlays = 
    [ 
      self.overlays.mc-rtc-pkgs 
      (final: prev: { jrl-cmakemodulesv2 = jrl-cmakemodulesv2.packages.${prev.system}.default; })
    ];
    # Set permittedInsecurePackages for all pkgs instances
    flakoboros.nixpkgsConfig =
    {
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };
}
