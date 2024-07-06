{ pkgs, wantedBy, ... }:
{

  systemd = {
    user.services.polkit-pantheon-authentication-agent-1 = {
      description = "polkit-pantheon-authentication-agent-1";
      wantedBy = [ wantedBy ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.pantheon.pantheon-agent-polkit}/libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
