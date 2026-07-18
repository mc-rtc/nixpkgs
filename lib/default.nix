{
  ...
}:
rec {
  # To test in nix repl
  # :lf .
  # pkgs = packages.x86_64-linux

  /**
    Converts a list of strings or derivations into a list of derivations from pkgs.

    Arguments:
      pkgs: The package set to resolve string names to derivations.
      vals: A list of strings (attribute names) or derivations.

    Example:
      lib.convertListToDrvs pkgs [ pkgs.human-mj-description "human-mj-description" ]

    Type: pkgs: AttrSet -> vals: [ String | Derivation ] -> [ Derivation ]
  */
  convertListToDrvs =
    pkgs: vals:
    map (
      x:
      if builtins.isAttrs x && x ? type && x.type == "derivation" then
        x
      else if builtins.isString x then
        builtins.getAttr x pkgs
      else
        throw "convertListToDrvs: unsupported type: ${builtins.typeOf x}"
    ) vals;

  /**
    Get a list of derivations from a passthru attribute (derivation or string or list of both) in a list of derivations.

    Arguments:
      pkgs: The package set to resolve string names to derivations.
      getField: A function that extracts the attribute from a derivation (e.g., `drv: drv.passthru.robot.module`).
      drvs: A list of derivations containing the field.

    Example:
      lib.drvsFromPassthruField pkgs (drv: drv.passthru.robot.module) [ pkgs.human-mj-description pkgs.g1-mj-description ]

    Type: pkgs: AttrSet -> getField: (Derivation -> a) -> drvs: [ Derivation ] -> [ Derivation ]
  */
  drvsFromPassthruField =
    pkgs: getField: drvs:
    let
      names = builtins.concatMap (field: if builtins.isList field then field else [ field ]) (
        map getField drvs
      );
    in
    convertListToDrvs pkgs names;

}
