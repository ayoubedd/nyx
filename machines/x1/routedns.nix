{ lib, pkgs, ... }:
{
  services.resolved.enable = lib.mkForce false;
  networking.resolvconf.useLocalResolver = true;

  services.routedns = {
    enable = true;
    configFile = pkgs.writeText "config" ''
      [bootstrap-resolver]
      address = "8.8.8.8:853"
      protocol = "dot"

      # ----------------- Cloudflare ------------------

      [resolvers.cloudflare-1-1-1-1-dot]
      address = "1.1.1.1:853"
      protocol = "dot"

      [resolvers.cloudflare-1-0-0-1-dot]
      address = "1.0.0.1:853"
      protocol = "dot"

      [groups.cloudflare-dot]
      resolvers = ["cloudflare-1-1-1-1-dot", "cloudflare-1-0-0-1-dot"]
      type = "fail-rotate"

      # ----------------- Google ------------------

      [resolvers.google-8-8-8-8-dot]
      address = "8.8.8.8:853"
      protocol = "dot"

      [resolvers.google-8-8-4-4-dot]
      address = "8.8.4.4:853"
      protocol = "dot"

      [groups.google-dot]
      resolvers = ["google-8-8-8-8-dot", "google-8-8-4-4-dot"]
      type = "fail-rotate"

      # ----------------- Merge ------------------

      [groups.main]
      type   = "fastest"
      resolvers = ["cloudflare-dot", "google-dot"]

      [groups.main-updated-ttl]
      type = "ttl-modifier"
      resolvers = ["main"]
      ttl-min = 300
      ttl-max = 86400
      ttl-select = "average"
      #
      [groups.main-cached]
      type = "cache"
      resolvers = ["main-updated-ttl"]
      backend = {type = "memory", size = 10000}
      cache-answer-shuffle = "round-robin"

      [groups.main-prefetch]
      type = "prefetch"
      resolvers = ["main-cached"]
      prefetch-window = "15m"
      prefetch-threshold = 3
      prefetch-cache-size = 150
      prefetch-max-items = 50


      [routers.main-router]
      routes = [
        { resolver="main-prefetch" }, # default route
      ]

      [listeners.local-udp-ipv4]
      address = "127.0.0.1:53"
      protocol = "udp"
      resolver = "main-router"

      [listeners.local-tcp-ipv4]
      address = "127.0.0.1:53"
      protocol = "tcp"
      resolver = "main-router"

      [listeners.local-udp-ipv6]
      address = "[::1]:53"
      protocol = "udp"
      resolver = "main-router"

      [listeners.local-tcp-ipv6]
      address = "[::1]:53"
      protocol = "tcp"
      resolver = "main-router"
    '';
  };
}
