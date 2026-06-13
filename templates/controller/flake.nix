{
  description = "mc-rtc-superbuild release and development shells";

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
          inputs.mc-rtc-nix.flakeModule
          {
            # This mc-rtc-superbuild configuration will:
            # - Define named reusable configurations in `configurations`
            # - Use explicit runtime (Nix runtime components) vs devel (local/source overlays)
            # - Generate `${project.pname}` and `${project.pname}-devel` shells from `defaults`
            #
            # This will also generate a .superbuild/mc_rtc.yaml file containg the suitable mc_rtc configuration
            # Devel dependencies are expected to be installed manually in .superbuild/install
            #
            # As always, indivdual packages can be overridden using flakoboros
            mc-rtc-superbuild = {
              enable = true;

              configurations = {
                default = {
                  runtime = { };
                };
              };

              defaults = {
                package = "default";
                develShell = "default";
                releaseShell = "full";
              };

              project = {
                pname = "mc-rtc-superbuild";
                configuration = "default";

                runtime = {
                  controllers = [ ];
                  robots = [ ];
                  plugins = [ ];
                  observers = [ ];
                  config = "lib/mc_controller/etc/<controller_name>/mc_rtc.yaml";
                };

                devel = {
                  controllers = [ ];
                  plugins = [ ];
                  robots = [ ];
                  observers = [ ];
                  config = "lib64/mc_controller/etc/<controller_name>/mc_rtc.yaml";
                };
              };
            };

            flakoboros = {
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
      }
    );
}
