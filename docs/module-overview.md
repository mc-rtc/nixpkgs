# Module overview

Our module is based on `flakoboros` circular packaging concept, and uses `flakoboros` extensively. Please familiarize yourself with `flakoboros` first by reading [their documentation](https://gepetto.github.io/flakoboros/index.html).

The concept is to define a `flake.nix` file in your own projects that include the module provided by this repository. This will:
- Make all packages of the `mc_rtc` ecosystem through overlays
- Allow you to modify/extend their packages through flakoboros's overrides (see [flakoboros overrides documentation](https://gepetto.github.io/flakoboros/overlay-flakoboros.html))
- Provide an `mc-rtc-superbuild` shell configurable though options to configure `mc_rtc`'s runtime dependencies (plugins, controllers, robots, etc) for your project

## Creating a new controller

To get started, use:

```
# create a new project folder initialized with a controller
nix shell github:mc-rtc/nixpkgs#mc-rtc -c mc_rtc_new_fsm_controller TestController TestController
cd TestController
# adds our nix flake
nix flake new -t github:mc-rtc/nixpkgs#controller
```

You should get (simplified here):

```nix
{
  description = "mc-rtc-superbuild release and development shells";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = import inputs.systems;
        imports = [
          inputs.mc-rtc-nix.flakeModule
          {
            mc-rtc-nix = {}; # options for mc-rtc-nix
            mc-rtc-superbuild = {}; # options for building superbuild shells
            flakoboros = {}; # flakoboros configuration
          }
        ];
      }
    );
}
```
