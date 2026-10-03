{ pkgs, ... }:
{
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    earlyoom.enable = true;
    dbus.packages = [
      pkgs.gnome-keyring
      pkgs.gcr_4
    ];
  };

  services.flatpak.enable = true; # Enable Flatpak
}
