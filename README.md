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
6. Run `nix-shell --pure --arg with-tvm true`

### Options

- `with-tvm`
  - `false` (default) gets you the master version of mc_rtc
  - `true` gets you the experimental/preview version of mc_rtc + TVM

- `with-ros`
  - `true` (default) build mc_rtc with ROS support
  - `false` build mc_rtc without ROS support

- `with-udp`
  - `false` (default) runs a simple ticker (similar to `mc_rtc_ticker`)
  - `true` runs `MCUDPControl`

Each argument must be specified with `--arg`, for example:

```bash
# Run MCUDPControl with vanilla mc_rtc and no ROS support
nix-shell --pure --arg with-tvm false --arg with-udp true --arg with-ros false
```

Run your own controller
--

`shell.nix` contains a simple example to show how to point nix to your local source for trying out your code on mc_rtc 2.0.0, you should change the following:

1. Change `enabled` to your controller name
2. Point the src attribute of the `my-controller` derivation to your local source folder
3. Add `(pkgs.callPackage my-controller {})` in mc-rtc plugins list

If you need extra dependencies you should add them as arguments to the derivation and in the `buildInputs` array.

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
- [ ] Better document how-to use this to test mc_rtc 2.0.0
