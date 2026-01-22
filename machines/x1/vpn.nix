{ config, ... }:
{
  networking.wireguard.enable = true;

  networking.wg-quick.interfaces = {
    homelab = {
      autostart = false;
      type = "wireguard";
      address = [ "10.100.0.2/32" ];
      listenPort = 1235;
      mtu = 1360;
      privateKeyFile = config.sops.secrets.wireguard-privatekey.path;
      peers = [
        {
          publicKey = "Vop9YfQn9rwtRaPAc/mxWV+NSXbZCZqlWoVwDoCzT2w=";
          allowedIPs = [
            "10.1.2.0/24"
            "10.1.1.0/24"
          ];
          endpoint = "casa-vpn.ayoubedd.me:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
