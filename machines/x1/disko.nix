{ config, lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "ESP";
            label = "NIXBOOT";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "rw"
                "relatime"
                "fmask=0077"
                "dmask=0077"
                # "errors=remount-ro 0 2"
              ];
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "luks";
              name = "root";
              settings.allowDiscards = true;
              passwordFile = config.sops.secrets.luks_passphrase.path;
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
