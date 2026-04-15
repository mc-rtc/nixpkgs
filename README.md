Nix flake for mc-rtc and related project
==

🚧 Welcome to mc-rtc's nixpkgs flake<br/>
🚧 This repository is an ongoing effort of packaging the mc-rtc ecosystem under Nix<br/>
🚧 Flake API and overlay structure may change without notice

Current status:
- [x] Default devShell: `mc-rtc-superbuild`
      Allows to build mc-rtc and configure its runtime dependencies (`robots`, `controllers`, `observers`, `plugins`)
- [x] Run `MCFrankaControl` with real Panda robots
- [x] `mc-rtc-magnum` support (with older `glfw/imgui/implot` as submodules, as done in `mc-rtc-superbuild`)
- [ ] Robots - all most commonly used robots are supported:
  - [x] JVRC1
  - [x] HRP-2Kai
  - [x] HRP-4
  - [x] HRP-5P
  - [x] H1
  - [x] Panda*
  - [x] PandaLIRMM*
  - [x] RHPS1
  - [ ] UR
    - [x] UR5e
    - [ ] UR10
- [ ] Controllers
  - [x] Rolkneematics `panda-prosthesis` (through downstream flake in `panda-prosthesis` repository)
  - [ ] WIP: Hugo's polytopeController
- [ ] `mc-mujoco`: building and running but some HiDPI scaling issues on Wayland with glfw 3.4
- [ ] magnum packaging (external): in progress
  - [x] magnum
    - [x] SDL2Application: works
    - [x] GlfwApplication:
      - [ ]HiDPI scaling issue on Wayland with GlfW 3.4, works otherwise
  - [x] magnum-plugins (only those needed by `mc-rtc-magnum`/`mc-mujoco`
  - [x] magnum-integration

Usage
--

### Locally

1. Install [Nix](https://nixos.org/download.html) on your system
2. Install [cachix](https://github.com/cachix/cachix)
3. Enable the cachix cache (some user configuration)
4. Clone this repository
5. Navigate to the cloned folder
6. Run `nix develop`

### Options

Options are provided through env variables

- `MC_RTC_WITH_ROS="1"`: build `mc-rtc` and depencencies (e.g robots) with ros support (ros2 humble) [default=1]
- `MC_RTC_USE_LOCAL="1"`: for derivations in `overlay.nix` that are called with `useLocal = true` (using `callWithLocal ...`), use a cloned folder in `localWorkspace` folder. This is not intended to be kept long-term, mostly a convenient debugging option until this repo is stable.

### Override the shell's environment for local development

To override the default shell environment to use your own local version of a controller, you can do

```sh
mkdir -p nix-workspace/install nix-workspace/devel
```

now create a `.direnv` file with the following content

```sh
# Do not auto-update the flake, do so manually through nix-direnv-reload
# This avoids triggering potentially long compilations upon entering a shell
nix_direnv_manual_reload

# Use this flake
use flake https://github.com/mc-rtc/nixpkgs

# or use a local copy for development
# export MC_RTC_WITH_ROS=1
# export MC_RTC_USE_LOCAL=1
# use flake nixpkgs --impure # if you cloned it locally in ./nixpkgs

# Override LD_LIBRARY_PATH and PATH to use the local install folder for your custom controller
export LD_LIBRARY_PATH=$PWD/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PWD/install/lib64:$LD_LIBRARY_PATH
export PATH=$PWD/install/bin:$PATH
# convenient cmake alias to ensure that the controller is installed in the expected local path
alias cmake_local="cmake -DCMAKE_PREFIX_PATH=$PWD/install -DMC_RTC_HONOR_INSTALL_PREFIX=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja"
```

Then run `direnv allow`. Upon entering the nix-workspace folder, this will setup the environment for you.

Now if you wish to install a custom controller/...

```sh
cd nix-workspace/devel
git clone <your_controller>
cd <your_controller>
```

Create a `.envrc` file here
```sh
source_up
export MC_RTC_CONTROLLER_CONFIG="$PWD/../install/lib64/mc_controller/etc/mc_rtc.yaml:MC_RTC_CONTROLLER_CONFIG"
```

Then run `direnv allow` again. This will add your controller to the `MC_RTC_CONTROLLER_CONFIG` variable. To build:

```sh
mkdir build
cd build
cmake_local ..
```

Define your own superbuild
--

This is still a WIP, but the gist of it is:
- define a derivation in your overlay containing all the derivations you wish to have available to mc-rtc. Runtime dependencies are passed to the `robots/controllers/observers/plugins` list and a corresponding `mc_rtc.yaml` containing the required library paths is auto-generated and added to `MC_RTC_CONTROLLER_CONFIG` env variable.

  ```nix
  mc-rtc-superbuild-rolkneematics = final.mc-rtc-superbuild.overrideAttrs (old: {
    robots = [
      # note that panda-prosthesis is not strictly-speaking a robot, but it builds a robot module so we need it here as well to populate the robots runtime paths
      panda-prosthesis
      mc-panda-lirmm
      mc-panda
    ];
    controllers = [ panda-prosthesis ];
    # extra mc_rtc.yaml
    configs = [ "${panda-prosthesis}/lib/mc_controller/etc/mc_rtc.yaml" ];
    observers = [];
    plugins = [ panda-prosthesis mc-force-shoe-plugin ];
    apps = [ mc-rtc-magnum mc-franka mc-rtc-ticker sch-visualization ];
  });
  ```

  Full doc coming soon...

Run your own controller
--

```bash
# if cachix is setup correctly this should just pull binary dependencies. Otherwise
# it will build everything specified in the `mc-rtc-superbuild` derivation (and their depencencies)
nix develop
# or nix develop .#mc-rtc-superbuild-rolkneematics # if you want to use your own derivation
mc-rtc-magnum &
# By default mc_rtc_ticker will use the configuration provided by `MC_RTC_CONTROLLER_CONFIG` env variable
# This is set by the mc-rtc-superbuild derivation and devShell to contain all needed runtime depencencies
# and optionally a default controller's configuration
mc_rtc_ticker
```
