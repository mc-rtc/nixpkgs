{ lib }:

cfg:

let
  mkComponent = {
    apps = [ ];
    robots = [ ];
    controllers = [ ];
    observers = [ ];
    plugins = [ ];
    config = null;
    extraConfigFiles = [ ];
  };

  mkRuntime = mkComponent;

  # 1. Added defaults to mkPreset
  mkPreset = {
    mainRobot = null;
    enabled = null;
    timeStep = null;
    runtime = mkRuntime;
    devel = mkComponent;
  };

  preferString = previous: next: if next != null && next != "" then next else previous;
  preferNumber = previous: next: if next != null then next else previous;

  mergeComponent = left: right: {
    apps = lib.unique (left.apps ++ right.apps);
    robots = lib.unique (left.robots ++ right.robots);
    controllers = lib.unique (left.controllers ++ right.controllers);
    observers = lib.unique (left.observers ++ right.observers);
    plugins = lib.unique (left.plugins ++ right.plugins);
    config = preferString left.config right.config;
    extraConfigFiles = lib.unique (left.extraConfigFiles ++ right.extraConfigFiles);
  };

  mergeRuntime = mergeComponent;

  mergePreset = left: right: {
    mainRobot = preferString (left.mainRobot or null) (right.mainRobot or null);
    enabled = preferString (left.enabled or null) (right.enabled or null);
    timeStep = preferNumber (left.timeStep or null) (right.timeStep or null);
    runtime = mergeRuntime left.runtime right.runtime;
    devel = mergeComponent left.devel right.devel;
  };

  foldPresets = presets: lib.foldl' mergePreset mkPreset presets;

  resolveNamedPreset =
    name: stack:
    if builtins.elem name stack then
      throw "mc-rtc-superbuild: cyclic configuration inheritance detected: ${toString (stack ++ [ name ])}"
    else if !(builtins.hasAttr name cfg.configurations) then
      throw "mc-rtc-superbuild: unknown configuration '${name}'"
    else
      let
        preset = cfg.configurations.${name};
        parents = map (parent: resolveNamedPreset parent (stack ++ [ name ])) preset.extends;
      in
      foldPresets (parents ++ [ preset ]);

  project = cfg.project;

  # 2. Ensured overlay includes configuration items from project top-level
  projectOverlay = {
    mainRobot = project.mainRobot or null;
    enabled = project.enabled or null;
    timeStep = project.timeStep or null;
    runtime = project.runtime;
    devel = project.devel;
  };

  selectedConfiguration = project.configuration;
  selectedPreset =
    if builtins.hasAttr selectedConfiguration cfg.configurations then
      resolveNamedPreset selectedConfiguration [ ]
    else if cfg.configurations == { } then
      mkPreset
    else
      throw "mc-rtc-superbuild: unknown project.configuration '${selectedConfiguration}'";

  base = mergePreset selectedPreset projectOverlay;

  release = {
    runtime = mergeRuntime base.devel base.runtime;
    devel = mkComponent;
  };

  devel = {
    runtime = base.runtime;
    devel = base.devel;
  };

in
{
  inherit
    mkComponent
    mkRuntime
    mkPreset
    selectedConfiguration
    ;
  # 3. Made mainRobot, enabled, and timeStep directly available at the root of resolved
  resolved = {
    mainRobot = base.mainRobot;
    enabled = base.enabled;
    timeStep = base.timeStep;
    inherit base release devel;
  };
}
