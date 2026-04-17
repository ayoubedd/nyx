{ ... }:
{
  systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall.enable = true;

  networking.nameservers = [
    "1.1.1.1#cloudflare-dns.com"
    "1.0.0.1#cloudflare-dns.com"
    "9.9.9.9#dns.quad9.net"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve.fallbackDns = [
      "8.8.8.8#dns.google"
      "8.4.4.8#dns.google"
    ];
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
