{ ... }: {
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.nftables.enable = true;

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.4.4.8"
    ];
  };
}
