{ ... }: {
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTarget = "hyprland-session.target";
  };
}
