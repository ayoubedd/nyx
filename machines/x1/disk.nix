{ config, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = "/dev/nvme0n1";
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
                "umask=0077"
                "dmask=0077"
              ];
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              passwordFile = config.sops.secrets.luks_passphrase.path;
              extraOpenArgs = [
                "--allow-discards"
                "--perf-no_read_workqueue"
                "--perf-no_write_workqueue"
              ];
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = [
                  "token-timeout=10"
                  "tpm2-device=auto"
                  "tpm2-pcrs=0"
                  "tpm2-measure-pcr=yes"
                  "x-initrd.attach"
                ];
              };
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
