{ ... }: {
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.4.4.8"
    ];
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
