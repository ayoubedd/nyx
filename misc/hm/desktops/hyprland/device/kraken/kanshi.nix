{ ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile.name = "main";
        profile.outputs = [
          {
            criteria = "DP-3";
            adaptiveSync = true;
            status = "enable";
            mode = "1920x1080@119.98Hz";
          }
        ];
      }
    ];
  };
}
