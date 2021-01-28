mc_rtc - Nix package
==

This repository hosts a nix overlay for mc_rtc.

This is especially meant to be used to tests controllers in clean environments, in particular during the mc_rtc "vanilla" edition and mc_rtc with TVM (i.e. mc_rtc 2.0.0)

Usage
--

### Locally

1. Install [Nix](https://nixos.org/download.html) on your system
2. Install [cachix](https://github.com/cachix/cachix): `nix-env -iA cachix -f https://cachix.org/api/v1/install`
3. Enable the ROS cache: `cachix use ros`
4. Clone this repository
5. Navigate to the cloned folder
6. Run `nix-shell --pure --arg with-tvm true`

- `with-tvm` can have two values
  - `false` gets you the master version of mc_rtc
  - `true` gets you the experimental/preview version of mc_rtc + TVM

This uses the file under `etc/mc_rtc.yaml` for configuration.

You can build [mc_rtc-raylib](https://github.com/gergondet/mc_rtc-raylib/) locally to visualize both variants output, or build and run it locally:

```bash
nix-shell display.nix --pure
```

Planned features
--

- [ ] Enable mc_openrtm in Nix (requires Choreonoid to build in Nix first)
- [ ] Better document how-to use this to test mc_rtc 2.0.0
