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

  mkPreset = {
    runtime = mkRuntime;
    devel = mkComponent;
  };

  preferString = previous: next:
    if next != null && next != "" then next else previous;

  mergeComponent = left: right: {
    apps = left.apps ++ right.apps;
    robots = left.robots ++ right.robots;
    controllers = left.controllers ++ right.controllers;
    observers = left.observers ++ right.observers;
    plugins = left.plugins ++ right.plugins;
    config = preferString left.config right.config;
    extraConfigFiles = left.extraConfigFiles ++ right.extraConfigFiles;
  };

  mergeRuntime = mergeComponent;

  mergePreset = left: right: {
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

  projectOverlay = {
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
    runtime = mergeRuntime base.runtime base.devel;
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
  resolved = {
    inherit base release devel;
  };
}
