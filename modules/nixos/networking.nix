{ ... }: {
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
}
