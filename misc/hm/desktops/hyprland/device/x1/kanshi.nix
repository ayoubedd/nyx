{ ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "normal";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "usbc-direct-dp-3";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-3";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "usbc-direct-dp-6";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-6";
            status = "enable";
          }
        ];
      }
    ];
  };

}
