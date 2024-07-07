{ ... }: {
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTarget = "hyprland-session.target";
  };

  services.gnome-keyring = {
    enable = true;
  };

  services.poweralertd.enable = true;
}
