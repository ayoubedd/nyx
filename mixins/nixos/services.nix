{ pkgs, ... }: {
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    flatpak.enable = true;
    earlyoom.enable = true; # Trigger oom early before systems becomes unusable
    dbus.packages = [ pkgs.gcr ];
  };
}
