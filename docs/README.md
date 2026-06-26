# mc-rtc-nix : the mc_rtc ecosystem in Nix

> [!WARNING]
> While being used daily by core maintainers of the framework, this is still considered a work-in-progress and usage / design choice may
> chage without notice.

This project contains:
- Package definitions for most of the mc_rtc ecosystem:
  - core framework `mc_rtc` and its dependencies
  - tools (`mc-rtc-magnum` for vizualisation, etc)
  - most robots supported by the framework, in particular those used at LIRMM and JRL
  - a limited set of downstream controllers and plugins
  - and more
- They are:
  - exposed in an overlay...
  - ...with a reusable flake module built on top of [flakoboros](https://gepetto.github.io/flakoboros) for easy integration in your projects with:
    - options to control how to build the framework in `mc-rtc-nix.<option>` (e.g `with-ros=false`, `overlays.private=true`, etc)
    - a superbuild module similar to `mc-rtc-superbuild` to configure the runtime dependencies of your project in `mc-rtc-superbuild.<options>`

Here is a quick primer on how to use its features:

## Setup Nix

If you are here and don't have nix yet, here is probably the easiest and fastest way to get started on ubuntu >= 24.04 "noble" / debian >= 13 "trixie" (because we need nix >= 2.18):

```
# 1. install the right apt package
sudo apt install -y nix-setup-systemd

# 2. activate the new CLI and flake features
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf

# 3. (optional) if you trust us, add our binary caches to avoid recompiling everything
echo 'extra-substituters = https://gepetto.cachix.org https://attic.iid.ciirc.cvut.cz/ros https://mc-rtc-nix.cachix.org' | sudo tee -a /etc/nix/nix.conf
echo 'extra-trusted-public-keys = gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY= ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q= mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs=' | sudo tee -a /etc/nix/nix.conf

# 4. activate your new nix.conf
sudo systemctl restart nix-daemon

# 5. allow yourself to use nix
sudo usermod -aG nix-users $(whoami)
newgrp nix-users

# 6. test everything is fine
nix run nixpkgs#ponysay it works
```

### Other setup methods

If you don't want this `nix-setup-systemd` apt package, other options include:

- Nix installer: <https://nixos.org/download/>
- Nix installer beta: <https://github.com/NixOS/nix-installer>
- Lix installer: <https://lix.systems/install/>

## Use mc-rtc-nix directly

This [mc-rtc/nixpkgs] repository exposes packages, some of which may be used directly. To try out `mc_rtc`, you can use:

```
nix develop github:mc-rtc/nixpkgs#mc-rtc-superbuild-default
```

This will put you in a shell with `mc_rtc` and its default robots/controllers installed. To get started, use

```
(mc-rtc-magnum &) # run visualizer in the background
mc_rtc_ticker # run an open-loop controller
```

You should see the `JVRC1` robot appear in the visualizer. If that is not the case and you are not on `NixOS`, you may need to configure Nix to use your graphics drivers. This can be achieved with

```
sudo nix run github:gepetto/nix#system-manager -- switch --flake github:gepetto/nix
```

> [!WARNING]
> This will install configurations system-wide (hence the sudo). If you are ensure about it, please read about [system-manager](https://system-manager.net/main/)

