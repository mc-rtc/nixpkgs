{
  lib,
  ...
}:
rec {
  # To test in nix repl
  # :lf .
  # pkgs = packages.x86_64-linux

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
          if builtins.hasAttr x pkgs then
            builtins.getAttr x pkgs
          else if ignoreMissing then
            builtins.trace "convertListToDrvs: ignoring missing derivation '${x}'" null
          else
            throw "convertListToDrvs: unsupported string or missing derivation: ${x}"
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
    in
    {
      extends = extends;
      runtime = {
        controllers = [ controller-drv ];
        plugins = convertListToDrvsStrict pkgs (c.plugins or [ ]);
        observers = convertListToDrvsStrict pkgs (c.observers or [ ]);
      }
      // lib.optionalAttrs with-suggested (
        let
          s = c.suggests or { };
        in
        {
          apps = convertListToDrvs pkgs (s.apps or [ ]);
          robots = convertListToDrvs pkgs (s.robots or [ ]);
        }
      );
      devel = {
        controllers = [ controller-drv ];
      };
    }
    // lib.optionalAttrs (c.controller.Enabled != null && c.controller.Enabled != "") {
      enabled = c.controller.Enabled;
    };

}
