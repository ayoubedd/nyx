{ flake-utils, ... }: {
  forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) flake-utils.lib.defaultSystems);
}
