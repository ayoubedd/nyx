{ config, pkgs, ... }:
{
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    yubioath-flutter
    sbctl # secure boot
  ];

  services.udev.packages = with pkgs; [ yubikey-personalization ];

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

  services.usbguard = {
    enable = true;
    implicitPolicyTarget = "block";
    IPCAllowedUsers = [
      "root"
      "orbit"
    ];
    rules = ''
      allow id 1d6b:0002 serial "0000:00:0d.0" name "xHCI Host Controller" hash "d3YN7OD60Ggqc9hClW0/al6tlFEshidDnQKzZRRk410=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:00:0d.0" name "xHCI Host Controller" hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" parent-hash "Y1kBdG1uWQr5CjULQs7uh2F6pHgFb6VDHcWLk83v+tE=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "prM+Jby/bFHCn2lNjQdAMbgc6tse3xVx+hZwjOPHSdQ=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 06cb:00fc serial "26f9264e7de3" name "" hash "41CoCmCOyBJLNii6ProaAOV9Oduob9jhkrPNj5LBz3k=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface ff:00:00 with-connect-type "not used"
      allow id 04f2:b6ea serial "0001" name "Integrated Camera" hash "odCaanbwFexqJbPU09iCW2UC7QaqEyN3q3BjF7zCdV0=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "not used"
      allow id 8087:0026 serial "" name "" hash "Z5csNGxiUukPPZwSHPyUqpVCNagsfOSSNL2CfXhw4IY=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"
    '';
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
