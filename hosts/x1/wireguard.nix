{ config, ... }: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    #"wg0" is the network interface name. You can name the interface arbitrarily.
    homelab = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.100.0.2/32" ];
      listenPort =
        1235; # to match firewall allowedUDPPorts (without this wg uses random port numbers)
      mtu = 1360;
      # Path to the private key file.
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.

      privateKeyFile = config.sops.secrets.wireguard-privatekey.path;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = "Vop9YfQn9rwtRaPAc/mxWV+NSXbZCZqlWoVwDoCzT2w=";
          # Forward all the traffic via VPN.
          allowedIPs = [ "10.1.2.0/24" "10.1.1.0/24" ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "11.111.11.0/22" ];
          # Set this to the server IP and port.
          name = "x1";
          endpoint =
            "casa-vpn.ayoubedd.me:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
