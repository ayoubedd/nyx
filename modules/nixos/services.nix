{ ... }: {
  services = {
    openssh.enable = true;
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    flatpak.enable = true;
  };
}
