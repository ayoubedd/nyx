{ pkgs, ... }: {
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

    hyprlock = { fprintAuth = false; };

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
}
