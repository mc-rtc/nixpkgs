{
  description = "Flake example for an mc-rtc controller with a superbuild shell";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";

    # You can override dependencies from a commit/pull request by:
    # Adding it as input
    # your-repository.url = "github:username/repository/pull/ID/head";
    # your-repository.flake = true; # use false if the repository does not have a flake
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = import inputs.systems;
        imports = [
          # available flakeModules modules are:
          # - flakeModule : default module, with overlays for all public repositories in mc-rtc ecosystem
          # - flakeModules.default : same as flakeModule
          # - flakeModules.ccache : same as default but built with ccache
          # - flakeModules.private : private module, with overlays for all public and private repositories in mc-rtc ecosystem.
          #   Please note that some repositories and the private cache require permission
          #   If you have sufficient access, this is provided with through your SSH key / binary cache token
          # - flakeModules.private-ccache : same as private, but with ccache support
          inputs.mc-rtc-nix.flakeModule
          {
            flakoboros = {

              # Define a custom superbuild configuration
              # This will make all
              overrides.mc-rtc-superbuild =
                { pkgs-prev, ... }:
                let
                  cfg-prev = pkgs-prev.mc-rtc-superbuild.superbuildArgs;
                in
                {
                  superbuildArgs = cfg-prev // {
                    pname = "mc-rtc-superbuild-override";
                    # # for example, override any runtime dependency (robots, controllers, etc)
                    # # extend robots
                    # robots = cfg-prev.robots ++ [ pkgs-final.mc-hrp4 ];
                    # # override controllers
                    # controllers = [ pkgs-final.polytopeController ];
                    # configs = [ "${pkgs-final.polytopeController}/lib/mc_controller/etc/mc_rtc.yaml" ];
                    # plugins = [ pkgs-final.mc-force-shoe-plugin ];
                    # observers = [ pkgs-final.mc-state-observation ];
                    # apps = [];
                  };
                };

              # # Override all dependencies
              # # They are locked in flake.lock to the latest commit available at the time
              # # To update to all inputs' latest commit, use
              # # nix flake update
              # overrideAttrs.your-repository = {
              #   src = inputs.your-repository;
              # };
            };
          }
        ];
        perSystem =
          { pkgs, ... }:
          {
            # define a default devShell called with the superbuild configuration above
            # you can also override attributes to add additional shell functionality
            devShells.default =
              (pkgs.callPackage "${inputs.mc-rtc-nix}/shell.nix" {
                inherit (pkgs) mc-rtc-superbuild;
              }).overrideAttrs
                (old: {
                  shellHook = ''
                    ${old.shellHook or ""}

                    echo "Welcome to the ${pkgs.mc-rtc-superbuild.pname} devShell with the overridden mc-rtc-superbuild configuration!"
                  '';
                });
          };
      }
    );
}
