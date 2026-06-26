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
nix flake init -t github:mc-rtc/nixpkgs#controller
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

This:
- Declares the flake inputs
- Initializes a flake using `flake-parts`
- Declares the supported systems (`x86_64-linux`, `darwin`, etc).
- Imports our flake module.

You can configure the flake overlay with:

```nix
mc-rtc-nix
{
  with-ros = true; # whether to build with ROS
  with-python = true; # whether to build with python bindings
  overlays.private = false; # whether to include private repositories in the overlay (robots HRP, etc). You will need an SSH key and appropriate permissions to use them.
  # ...
}
```

To define a superbuild configuration for our example controller, we need two things:
1. Declare how to build the package itself (since this is not upstreamed here)
1. Tell `mc_rtc` how to use it.

We furthermore want the ability to:
1. Let nix deploy the project
1. Build and install it from source

This can be achieved as follows:

```nix
mc-rtc-superbuild =
{ pkgs, ... }:
{
  enable = true; # enables the mc-rtc-superbuild module
  project.pname = "test-controller-superbuild"; # prefix shell names
  configurations = { # adds configurations for your controller
    your-controller-minimal = {
      extends = [ "minimal" ]; # adds a configuration based on the "minimal" preset
      runtime = { # define runtime dependencies installed by nix
        robots = [];

        apps = [
          pkgs.mc-rtc-magnum
        ];
        config = "lib/mc_controller/etc/your-controller/mc_rtc.yaml";
      };
      # define devel dependencies:
      # - In devel shells, these are not built by Nix, you must build them from source.
      # - In release shells, they are merged wiith the runtime configuration
      # mc_rtc.yaml is configured to use them
      devel = {
        config = "lib64/mc_controller/etc/your-controller/mc_rtc.yaml";
        controllers = [ pkgs.test-controller];
      };
    };
  };
};
```

Now you can get a developpement shell, with the current source tree built by Nix with

```
nix develop .#test-controller-superbuild-minimal
```

Or built from source, with `mc_rtc`'s runtime paths pre-configured to use-it with

```
nix develop .#test-controller-superbuild-minimal-devel
cmake -B build $cmakeFlags -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -G Ninja
cmake --build build --target install
```

And execute in both cases with
```
(mc-rtc-magnum &) # visualization from apps category
mc_rtc_ticker # default open-loop control of mc_rtc
```
