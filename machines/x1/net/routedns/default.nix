{ lib, pkgs, ... }:
{
  services.resolved.enable = lib.mkForce false;
  networking.resolvconf.useLocalResolver = true;
  # The common "IP#SNI" nameservers are resolved-only syntax that glibc can't
  # parse. Without resolved, the DoT fallbacks live in config.toml instead.
  # Plain-IP entries would let glibc send queries unencrypted whenever
  # routedns is slow.
  networking.nameservers = lib.mkForce [ ];

  services.routedns = {
    enable = true;
    configFile = pkgs.writeText "config" (builtins.readFile ./config.toml);
  };
  systemd.services.routedns = {
    serviceConfig = {
      CacheDirectory = "routedns";
    };
  };
}
