{
  description = "Flake example for an mc-rtc controller with a superbuild shell";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";

    # To override dependencies according to a commit/pull request, add them to inputs
    # For example:
    # mc-force-shoe-plugin.url = "github:Hugo-L3174/mc_force_shoe_plugin/pull/16/head";
    # or use pull/N/merge to get the version merged with master, assuming there are no conflicts
    # mc-force-shoe-plugin.flake = false;
    # use true if the repository has a flake
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = import inputs.systems;
        imports = [
          inputs.mc-rtc-nix.flakeModulePrivate
          # or inputs.mc-rtc-nix.flakeModule if you don't need private repositories
          {
            flakoboros = {
              extraPackages = [ "ninja" ];

              # Override all dependencies
              # They are locked in flake.lock to the latest commit available at the time
              # To update to all inputs' latest commit, use
              # nix flake update
              # overrideAttrs.mc-force-shoe-plugin = {
              #   # src = lib.cleanSource /home/arnaud/devel/mc-rtc-nix/workspace/mc_force_shoe_plugin;
              #   src = inputs.mc-force-shoe-plugin;
              # };

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
                    # for example, override any runtime dependency (robots, controllers, etc)
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

            };
          }
        ];
        perSystem =
          { pkgs, ... }:
          {
            # define a devShell called local-superbuild with the superbuild configuration above
            # you can also override attributes to add additional shell functionality
            devShells.local-superbuild =
              (pkgs.callPackage "${inputs.mc-rtc-nix}/shell.nix" {
                inherit (pkgs) mc-rtc-superbuild;
              }).overrideAttrs
                (old: {
                  shellHook = ''
                    ${old.shellHook or ""}

                    echo "Welcome to the local-superbuild devShell with the overridden mc-rtc-superbuild configuration!"
                  '';
                });
          };
      }
    );
}
