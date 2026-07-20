{
  description = "CHANGEME";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";

    ccache-trigger.url = "github:boolean-option/true";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = import inputs.systems;
        imports = [
          inputs.mc-rtc-nix.flakeModule
          {
            # Configuration for the mc-rtc-nix module
            # Activate overlays, disable ros, etc
            mc-rtc-nix = {
              overlays.ccache = inputs.ccache-trigger.value;
            };

            # If you need a superbuild environment configure it here
            mc-rtc-superbuild = { };

            # Override dependencies with flakoboros module
            flakoboros = {
              overrideAttrs.CHANGEME = {
                src = lib.cleanSource ./.;
              };
            };
          }
        ];
      }
    );
}
