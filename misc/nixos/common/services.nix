{ pkgs, ... }:
{
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    earlyoom.enable = true;
    dbus.packages = [
      pkgs.gnome-keyring
      pkgs.gcr
    ];
  };

  services.flatpak.enable = true; # Enable Flatpak
}
