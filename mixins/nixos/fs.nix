{ ... }: {
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
}
