{ ... }:
{
  services.blueman-applet.enable = true;

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  services.network-manager-applet.enable = true;
}
