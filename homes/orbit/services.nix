{
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" ];
  };
}
