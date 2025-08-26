{ pkgs, ... }:
{
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [ yubikey-personalization ];
  environment.systemPackages = with pkgs; [ yubioath-flutter ];

  services.fprintd.enable = true;

  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
    id = [ "30617898" ];
  };

  security.pam.services = {
    login = {
      u2fAuth = true;
      enableGnomeKeyring = true;
      fprintAuth = false;
    };

    greetd = {
      u2fAuth = true;
      enableGnomeKeyring = true;
      fprintAuth = false;
    };

    hyprlock = {
      fprintAuth = false;
    };

    sudo = {
      u2fAuth = true;
      nodelay = true;
    };

    polkit-1 = {
      u2fAuth = true;
      nodelay = true;
    };
  };

  services.udev.extraRules = ''
    ACTION=="remove",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ( subject.isInGroup("users") && (
         action.id == "org.freedesktop.login1.reboot" ||
         action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
         action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.power-off-multiple-sessions"
        ))
        { return polkit.Result.YES; }
      })
    '';
  };
}
