{ lib, pkgs, ... }:
{
  services.resolved.enable = lib.mkForce false;
  networking.resolvconf.useLocalResolver = true;

  services.routedns = {
    enable = true;
    configFile = pkgs.writeText "config" (builtins.readFile ./config.toml);
  };
}
