{ lib, config, ... }: {
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = (!config.boot.tmp.useTmpfs);
}
