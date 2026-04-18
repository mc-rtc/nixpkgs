{
  pkgs,
  inputs',
  extraPackages ? { },
  extraDevShells ? { },
}:

{
  packages =
    inputs'.gepetto.packages
    // {
      # Main dependencies
      spacevecalg = pkgs.spacevecalg;
      rbdyn = pkgs.rbdyn;
      sch-core = pkgs.sch-core;
      tasks = pkgs.tasks;
      tasks-qld = pkgs.tasks-qld;
      tvm = pkgs.tvm;
      eigen-quadprog = pkgs.eigen-quadprog;
      eigen-qld = pkgs.eigen-qld;
      state-observation = pkgs.state-observation;
      mesh-sampling = pkgs.mesh-sampling;
      eigen-fmt = pkgs.eigen-fmt;

      # mc-rtc
      mc-rtc-data = pkgs.mc-rtc-data;
      mc-rtc = pkgs.mc-rtc;

      # Main GUIs and applications
      mc-rtc-magnum = pkgs.mc-rtc-magnum;
      mc-mujoco = pkgs.mc-mujoco;
      mc-rtc-ticker = pkgs.mc-rtc-ticker;
      # Control interfaces
      mc-franka = pkgs.mc-franka;

      # Main superbuild configurations
      mc-rtc-superbuild = pkgs.mc-rtc-superbuild;
      mc-rtc-superbuild-full = pkgs.mc-rtc-superbuild-full;
      # Main controllers
      panda-prosthesis = pkgs.panda-prosthesis;
      polytopeController = pkgs.polytopeController;

      # Main plugins
      mc-force-shoe-plugin = pkgs.mc-force-shoe-plugin;

      # Main robots
      mc-g1 = pkgs.mc-g1;
      mc-h1 = pkgs.mc-h1;
      mc-ur5e = pkgs.mc-ur5e;
      mc-panda = pkgs.mc-panda;
      mc-panda-lirmm = pkgs.mc-panda-lirmm;
    }
    // extraPackages;

  devShells =
    inputs'.gepetto.devShells
    // {
      mc-rtc-superbuild-minimal = import ./shell.nix {
        inherit pkgs;
        with-ros = true;
        mc-rtc-superbuild = pkgs.mc-rtc-superbuild-minimal;
      };
      mc-rtc-superbuild = import ./shell.nix {
        inherit pkgs;
        with-ros = true;
        mc-rtc-superbuild = pkgs.mc-rtc-superbuild;
      };
      mc-rtc-superbuild-all-public-robots = import ./shell.nix {
        inherit pkgs;
        with-ros = true;
        mc-rtc-superbuild = pkgs.mc-rtc-superbuild-all-public-robots;
      };
      mc-rtc-superbuild-full = import ./shell.nix {
        inherit pkgs;
        with-ros = true;
        mc-rtc-superbuild = pkgs.mc-rtc-superbuild-full;
      };
    }
    // extraDevShells;
}
