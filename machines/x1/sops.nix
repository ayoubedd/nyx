{ ... }:
{
  sops.defaultSopsFile = ../../secrets/x1.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/orbit/.config/sops/age/keys.txt";

  sops.secrets = {
    orbit_password = {
      neededForUsers = true;
    };

    root_password = {
      neededForUsers = true;
    };

    wg_privkey = {
      restartUnits = [ "wg-quick-homelab.service" "wg-quick-homelab-all.service" ];
    };

    luks_passphrase = {
      neededForUsers = true;
    };
  };
}
