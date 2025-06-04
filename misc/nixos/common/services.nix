{ pkgs, ... }: {
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    earlyoom.enable = true; # Trigger oom early before systems becomes unusable
    dbus.packages = [ pkgs.gcr ];
  };

  services.flatpak.enable = true; # Enable Flatpak

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
