{
  lib,
  ...
}:
rec {
  # To test in nix repl
  # :lf .
  # pkgs = packages.x86_64-linux

  convertPkgNameToDrv =
    {
      pkgs,
      name,
      ignoreMissing ? false,
    }:
    if builtins.hasAttr name pkgs then
      builtins.getAttr name pkgs
    else if ignoreMissing then
      builtins.trace "convertPkgNameToDrv: ignoring missing derivation '${name}'" null
    else
      throw "convertPkgNameToDrv: unsupported string or missing derivation: ${name}";

  /**
    Converts a list of strings or derivations into a list of derivations from `pkgs`.

    Arguments:

    - `pkgs`: The package set to resolve string names to derivations.
    - `vals`: A list of strings (attribute names) or derivations.
    - `ignoreMissing` (optional, default: `false`): If true, missing derivations are skipped with a warning.

    Returns:

    - A list of derivations, resolving strings via `pkgs`.

    @example
    ```nix
    lib._convertListToDrvs {
      pkgs = pkgs;
      vals = [ pkgs.human-mj-description "human-mj-description" ];
    }
    ```

    Type:
      { pkgs: AttrSet, vals: [String | Derivation], ignoreMissing?: Bool } -> [Derivation]
  */
  _convertListToDrvs =
    {
      pkgs,
      vals,
      ignoreMissing ? false,
    }:
    let
      toDrv =
        x:
        if builtins.isAttrs x && x ? type && x.type == "derivation" then
          x
        else if builtins.isString x then
          convertPkgNameToDrv {
            inherit pkgs ignoreMissing;
            name = x;
          }
        else
          throw "convertListToDrvs: unsupported type: ${builtins.typeOf x}";
    in
    builtins.filter (x: x != null) (map toDrv vals);

  /**
    Converts a list of strings or derivations into a list of derivations from `pkgs`, throwing an error if any string is not found.

    Arguments:

    - `pkgs`: The package set to resolve string names to derivations.
    - `vals`: A list of strings (attribute names) or derivations.

    Returns:

    - A list of derivations, resolving strings via `pkgs`. Throws an error if a string is missing.

    @example
    ```nix
    lib.convertListToDrvsStrict pkgs [ pkgs.human-mj-description "human-mj-description" ]
    lib.convertListToDrvsStrict pkgs [ "mc-hrp4" ]
    ```

    Type:
      pkgs: AttrSet -> vals: [String | Derivation] -> [Derivation]
  */
  convertListToDrvsStrict =
    pkgs: vals:
    _convertListToDrvs {
      inherit pkgs vals;
      ignoreMissing = false;
    };
  /**
    Converts a list of strings or derivations into a list of derivations from `pkgs`, skipping missing strings with a warning.

    Arguments:

    - `pkgs`: The package set to resolve string names to derivations.
    - `vals`: A list of strings (attribute names) or derivations.

    Returns:

    - A list of derivations, resolving strings via `pkgs`. Missing strings are skipped with a warning.

    @example
    ```nix
    lib.convertListToDrvs pkgs [ pkgs.human-mj-description "human-mj-description" ]
    lib.convertListToDrvs pkgs [ "mc-hrp4" ]
    ```

    Type:
      pkgs: AttrSet -> vals: [String | Derivation] -> [Derivation]
  */
  convertListToDrvs =
    pkgs: vals:
    _convertListToDrvs {
      inherit pkgs vals;
      ignoreMissing = true;
    };

  /**
    Returns a list of derivations from a passthru attribute (which may be a derivation, a string, or a list of both) in a list of derivations.

    Arguments:

    - `pkgs`: The package set to resolve string names to derivations.
    - `getField`: A function that extracts the attribute from a derivation (e.g., `drv: drv.passthru.robot.module`).
    - `drvs`: A list of derivations containing the field.

    Returns:

    - A flat list of derivations extracted from the passthru field of each input derivation.

    @example
    ```nix
    lib.drvsFromPassthruField pkgs (drv: drv.passthru.robot.module) [
      pkgs.human-mj-description
      pkgs.g1-mj-description
    ]
    ```

    Type:
      pkgs: AttrSet -> getField: (Derivation -> a) -> drvs: [Derivation] -> [Derivation]
  */
  drvsFromPassthruField =
    pkgs: getField: drvs:
    let
      names = builtins.concatMap (field: if builtins.isList field then field else [ field ]) (
        map getField drvs
      );
    in
    convertListToDrvs pkgs names;

  /**
    Gathers MuJoCo robot derivations from a list of robot modules.

    Each robot module should provide `passthru.mujocoRobots = [ "robot-mj-description" ]`.

    @param pkgs Set. The package set to look up derivations.
    @param robots List of derivations. The robot modules.
    @return List of derivations. The MuJoCo robot derivations from the modules.
  */
  mujocoRobotsFromRobotModules =
    pkgs: robots: drvsFromPassthruField pkgs (drv: drv.mujocoRobots) robots;

  /**
    Replaces the mc-mujoco derivation in the apps list with a version overridden with the given MuJoCo robots.

    If an app in the list is `pkgs.mc-mujoco`, it is replaced with an overridden version using the provided `mujocoRobots`.
    Other apps are left unchanged.

    @param apps List of derivations. The applications list.
    @param pkgs Set. The package set containing mc-mujoco and mc-mujoco-robots.
    @param mujocoRobots List of derivations. The MuJoCo robots to use in the override.
    @return List of derivations. The updated applications list.
  */
  replaceMcMujocoInApps =
    apps: pkgs: mujocoRobots:
    let
      addMujocoRobots = pkgs.mc-mujoco.override {
        mc-mujoco-robots = pkgs.mc-mujoco-robots.override {
          robots = mujocoRobots;
        };
      };
      isMcMujoco = app: app == pkgs.mc-mujoco;
    in
    map (app: if isMcMujoco app then addMujocoRobots else app) apps;

  /**
    mkControllerSuperbuild

    Constructs a superbuild attribute set for a given controller derivation.

    Arguments:

    - `pkgs`: The Nixpkgs package set.
    - `controller-drv`: The controller derivation (attribute set) to wrap.
    - `extends` (default: `[]`): List of superbuilds to extend from.
    - `with-suggested` (default: `true`): Whether to include suggested apps/robots.

    Returns:

    - extends:    The list of extended superbuilds.
    - runtime:    Runtime environment (controllers, plugins, observers).
    - apps:       (optional) Suggested apps, if with-suggested is true.
    - robots:     (optional) Suggested robots, if with-suggested is true.
    - devel:      Development environment (controllers).
    - enabled:    The enabled controller name, if set.

    Example

    ```nix
      let
        myControllerDrv = pkgs.stdenv.mkDerivation {
          name = "my-controller";
          # ... build instructions ...
          passthru = {
            plugins = [ footsteps-planner-plugin mc-joystick-plugin ];
            observers = [ some-observer ];
            controller = {
              Enabled = "ismpc_walking";
              MainRobot = "JVRC1";
            };
            suggests = {
              robots = [ "mc-hrp4" "mc-hrp2" ];
              apps = [ "mc-mujoco" ];
            };
          };
        };
      in
        mkControllerSuperbuild pkgs myControllerDrv { with-suggested = true; }
    ```
  */
  mkControllerSuperbuild =
    pkgs: controller-drv:
    {
      extends ? [ ],
      with-suggested ? true,
    }:
    let
      c = controller-drv.mc-rtc or { };
      s = c.suggests or { };
      convertStrict = attr: name: convertListToDrvsStrict pkgs (attr.${name} or [ ]);
      convertSuggested =
        attr: name: convertListToDrvs pkgs (lib.optionals with-suggested (attr.${name} or [ ]));
      robots = convertStrict c "robots" ++ convertSuggested s "robots";
      # Gather corresponding mj-description derivations
      mujocoRobots = drvsFromPassthruField pkgs (drv: drv.mujocoRobots) robots;
      apps = convertStrict c "apps" ++ convertSuggested s "apps";
      runApps = convertStrict c "runApps";
    in
    {
      extends = extends;
      runtime = {
        inherit robots;
        apps = replaceMcMujocoInApps apps pkgs mujocoRobots;
        runApps = replaceMcMujocoInApps runApps pkgs mujocoRobots;
        controllers = [ controller-drv ];
        plugins = convertStrict c "plugins" ++ convertSuggested s "plugins";
        observers = convertStrict c "observers" ++ convertSuggested s "observers";
      };
      devel = {
        controllers = [ controller-drv ];
      };
    }
    // lib.optionalAttrs (c.controller.Enabled != null && c.controller.Enabled != "") {
      enabled = c.controller.Enabled;
    }
    // lib.optionalAttrs (c.controller.MainRobot != null && c.controller.MainRobot != "") {
      mainRobot = c.controller.MainRobot;
    };
}
