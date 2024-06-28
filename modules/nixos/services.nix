{ ... }: {
  services = {
    openssh.enable = true;
    devmon.enable = true;
    libinput.enable = true;
    flatpak.enable = true;
  };
}
