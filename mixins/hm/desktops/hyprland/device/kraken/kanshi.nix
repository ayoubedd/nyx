{ ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      main = {
        outputs = [
          {
            criteria = "DP-3";
            adaptiveSync = true;
            status = "enable";
            mode = "1920x1080@119.98Hz";
          }
          {
            criteria = "Unknown-1";
            status = "disable";
          }
        ];
      };
    };
  };
}
