{ ... }: {
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall.enable = true;

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "8.8.8.8#dns.google"
      "8.4.4.8#dns.google"
    ];
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
