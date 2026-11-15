{ ... }:
{
  # services.blueman-applet.enable = true;

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  # Wi-Fi is handled by the quickshell bar (see ./quickshell/default.nix).
  # services.network-manager-applet.enable = true;
}
