{ ... }: {
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTarget = "hyprland-session.target";
    extraOptions = [ "-max-items" "100" ];
  };

  services.gnome-keyring = { enable = true; };

  services.poweralertd.enable = true;
  services.network-manager-applet.enable = true;
}
