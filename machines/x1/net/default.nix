{ config, ... }:
{
  imports = [
    ./routedns
  ];

  networking.wireguard.enable = true;

  networking.wg-quick.interfaces = {
    homelab = {
      autostart = false;
      type = "wireguard";
      address = [ "10.100.0.3/32" ];
      listenPort = 1235;
      mtu = 1360;
      privateKeyFile = config.sops.secrets.wg_privkey.path;
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

    tunnel = {
      autostart = false;
      type = "wireguard";
      address = [ "10.100.0.3/32" ];
      listenPort = 1235;
      mtu = 1360;
      privateKeyFile = config.sops.secrets.wg_privkey.path;
      peers = [
        {
          publicKey = "Vop9YfQn9rwtRaPAc/mxWV+NSXbZCZqlWoVwDoCzT2w=";
          allowedIPs = [
            "0.0.0.0/0"
          ];
          endpoint = "casa-vpn.ayoubedd.me:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
