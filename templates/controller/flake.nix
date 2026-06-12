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
            # - Generate a ${pname-devel} development shell wth all runtime dependencies in controllers/robots/plugins/observers
            #   installed by Nix, and all dependencies specified in `devel` attribute set used as `inputFrom`
            #   (e.g not built by Nix, but with their build dependencies available)
            # - Generate a ${pname} release shell with all runtime dependencies in both controllers/robots/plugins/observers and devel
            #   installed by Nix
            #
            # This will also generate a .superbuild/mc_rtc.yaml file containg the suitable mc_rtc configuration
            # Devel dependencies are expected to be installed manually in .superbuild/install
            #
            # As always, indivdual packages can be overridden using flakoboros
            mc-rtc-superbuild =
              { pkgs, ... }:
              {
                enable = true;
                pname = "mc-rtc-superbuild";

                # These runtime dependencies are installed by Nix in both devel and release shells
                controllers = [ ];
                robots = [ ];
                plugins = [ ];
                observers = [ ];
                apps = [ pkgs.mc-rtc-magnum ];
                # You controller's default mc_rtc.yaml configuration
                config = "lib/mc_controller/etc/<controller_name>/mc_rtc.yaml";

                # The devel configuration is used by ${pnanme}-devel shell as inputsFrom
                # You must install them manually
                devel = {
                  controllers = [ ];
                  plugins = [ ];
                  robots = [ ];
                  observers = [ ];
                  config = "lib64/mc_controller/etc/<controller_name>/mc_rtc.yaml";
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
