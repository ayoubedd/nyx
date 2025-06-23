{ pkgs, ... }: {
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    earlyoom.enable = true; # Trigger oom early before systems becomes unusable
    dbus.packages = [ pkgs.gnome-keyring pkgs.gcr ];
  };

  services.flatpak.enable = true; # Enable Flatpak
}
