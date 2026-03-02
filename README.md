mc_rtc - Nix package
==

This repository hosts a nix overlay for mc_rtc.

This is especially meant to be used to tests controllers in clean environments, in particular during the mc_rtc "vanilla" edition and mc_rtc with TVM (i.e. mc_rtc 2.0.0).

It is currently possible to run `MCUDPControl` within this setup and thus to run experiments on a robot that uses mc_udp servers.

Usage
--

### Locally

1. Install [Nix](https://nixos.org/download.html) on your system
2. Install [cachix](https://github.com/cachix/cachix): `nix-env -iA cachix -f https://cachix.org/api/v1/install`
3. Enable the ROS cache: `cachix use ros`
4. Clone this repository
5. Navigate to the cloned folder
6. Run `nix develop`

### Options

- `with-ros`
  - `true` (default) build mc_rtc with ROS support
  - `false` build mc_rtc without ROS support

### Override the shell's environment for local development

To override the default shell environment to use your own local version of a controller, you can do

```sh
mkdir -p nix-workspace/install nix-workspace/devel
```

now create a `.direnv` file with the following content

```sh
use flake https://github.com/mc-rtc/nixpkgs
# or 
# export MC_RTC_WITH_ROS=1
# export MC_RTC_USE_LOCAL=1
# use flake nixpkgs --impure # if you cloned it locally
export LD_LIBRARY_PATH=$PWD/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PWD/install/lib64:$LD_LIBRARY_PATH
export PATH=$PWD/install/bin:$PATH
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

Run your own controller
--

`shell.nix` contains a simple example to show how to point nix to your local source for trying out your code on mc_rtc 2.0.0, you should change the following:

1. Change `enabled` to your controller name
2. Point the src attribute of the `my-controller` derivation to your local source folder
3. Add `(pkgs.callPackage my-controller {})` in mc-rtc plugins list

If you need extra dependencies you should add them as arguments to the derivation and in the `buildInputs` array.

Migration from mc_rtc 1.x
--

A migration guide is provided on [mc_rtc wiki](https://github.com/jrl-umi3218/mc_rtc/wiki/Migration-from-mc_rtc-1.x-to-2.0.0)

Visualize the controller output
--

You can still visualize your controller output using your host RViZ installation:

```bash
roslaunch mc_rtc_ticker display.launch
```

You can also try [mc_rtc-raylib](https://github.com/gergondet/mc_rtc-raylib/) within nix:

```bash
nix-shell display.nix --pure
```

Note: If you are using an intel graphics card change `nixGLNvidia` to `nixGLIntel` in `display.nix`

Planned features
--

- [ ] Enable mc_openrtm in Nix (requires Choreonoid to build in Nix first)
