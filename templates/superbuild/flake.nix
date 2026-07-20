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
    /**
      This will:
      - Build the controller from the local sources in this repository
      - Generate mc-rtc-superbuild development shells from named configurations in 'configurations':
        - mc-rtc-superbuild-controller-<configuration>: a release shell allowing to run the controller
        - mc-rtc-superbuild-controller-<configuration>-devel : a development shell allowing to build the controller and run it
        Instructions are displayed upon entering the shells.

       You can control the behaviour or define your own shells with:
       mc-rtc-nix = {};
       mc-rtc-superbuild = {};

       This will also generate a mc_rtc.yaml file in $MC_RTC_CONTROLLER_CONFIG containg the suitable mc_rtc configuration
       Devel dependencies are expected to be installed manually in .superbuild/install
    */
    inputs.mc-rtc-nix.lib.mkMcRtcModule inputs (
      { lib, ... }:
      {
        #
        # As always, individual packages can be overridden using flakoboros
        mc-rtc-superbuild =
          { pkgs, ... }:
          {
            enable = true;
            project.pname = "";
            # TODO: replace this section with your own configuration presets for your project
            configurations = {
              your-project-minimal = {
                extends = [ "minimal" ];
                runtime = {
                  robots = [
                    pkgs.mc-panda-lirmm
                    pkgs.mc-panda
                  ];

                  apps = [
                    pkgs.mc-rtc-magnum
                  ];
                  config = "lib/mc_controller/etc/your-project/mc_rtc.yaml";
                };
                devel = {
                  config = "lib64/mc_controller/etc/your-project/mc_rtc.yaml";
                  controllers = [ pkgs.your-project ];
                  plugins = [ pkgs.your-project ];
                  robots = [ pkgs.your-project ];
                };
              };
              your-project-full = {
                extends = [
                  "default"
                  "your-project-minimal"
                ];
                runtime = {
                  apps = [
                    pkgs.mc-franka
                  ];
                };
              };
            };
          };

        flakoboros = {
          # Override dependencies
          # They are locked in flake.lock to the latest commit available at the time
          # To update to all inputs' latest commit, use
          # nix flake update
          overrideAttrs.your-project = {
            src = lib.cleanSource ./.;
          };
        };
      }
    );
}
