{ ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "sway-session.target";
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            adaptiveSync = true;
            scale = 2.0;
            status = "enable";
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HDMI-A-1";
            status = "enable";
          }
        ];
      };
    };
  };
}
