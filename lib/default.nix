{
  ...
}:
rec {
  # To test in nix repl
  # :lf .
  # pkgs = packages.x86_64-linux

  # Converts a list of strings or derivations into a list of derivations in pkgs
  #
  # Test with
  # lib.convertListToDrvs pkgs [ pkgs.human-mj-description "human-mj-description"]
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

  # Get a list of derivations from a passthru attribute (derivation or string or list of both) in a list of derivations
  # Args:
  # - pkgs
  # - getField: a function returning the attribute ex: (drv: drv.passthru.robot.module)
  # - drvs: a list of derivations containing the field
  #
  # Test with
  # lib.drvsFromPassthruField pkgs (drv: drv.passthru.robot.module) [ pkgs.human-mj-description pkgs.g1-mj-description ]
  drvsFromPassthruField =
    pkgs: getField: drvs:
    let
      names = builtins.concatMap (field: if builtins.isList field then field else [ field ]) (
        map getField drvs
      );
    in
    convertListToDrvs pkgs names;

}
