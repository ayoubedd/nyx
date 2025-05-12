{ ... }: {
  sops.defaultSopsFile = ../../secrets/orbit.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/orbit/.config/sops/age/keys.txt";

  sops.secrets = {
    user_password = { neededForUsers = true; };

    root_password = {
      sopsFile = ../../secrets/x1.yaml;
      neededForUsers = true;
    };

    wireguard-privatekey = {
      sopsFile = ../../secrets/homelab.yaml;
      restartUnits = [ "wireguard-homelab-peer-x1.service" ];
    };
  };
}
