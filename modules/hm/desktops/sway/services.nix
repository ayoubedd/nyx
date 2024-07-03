{ pkgs, ... }: {
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTarget = "sway-session.target";
  };

  services.swayidle =
    let
      swaymsg = "${pkgs.sway}/bin/swaymsg";
      sway = "${pkgs.sway}/bin/sway";
      swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
    in
    {
      enable = true;
      systemdTarget = "sway-session.target";
      events = [
        { event = "after-resume"; command = "${swaymsg} \"output * dpms on\""; }
        { event = "before-sleep"; command = "${swaylock} -fF"; }
      ];
      timeouts = [
        { timeout = 300; command = "${swaylock} -f --grace 10"; }
        { timeout = 400; command = "${swaymsg} \"output * dpms off\""; }
      ];
    };

  programs.swayr = {
    enable = true;
    systemd.enable = true;
    systemd.target = "sway-session.target";
  };
}
