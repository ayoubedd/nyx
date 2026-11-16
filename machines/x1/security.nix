{
  pkgs,
  lib,
  config,
  ...
}:
let
  targetUser = builtins.head (builtins.attrNames config.home-manager.users);
  userLibrewolf = config.home-manager.users.${targetUser}.programs.librewolf.finalPackage;

  # Starting rule set for USBGuard: the laptop's built-in devices (from
  # `usbguard generate-policy`) and the Razer mouse. Copied to
  # /var/lib/usbguard/rules.conf only if that file doesn't exist yet; after
  # that the file is the live rule set ("Allow always" appends to it).
  # Root hubs (1d6b:*) are matched without a hash: their descriptors (and so
  # their hashes) change with kernel updates.
  usbguardSeedRules = pkgs.writeText "usbguard-seed-rules" ''
    allow id 1d6b:0002 serial "0000:00:0d.0" name "xHCI Host Controller" with-interface 09:00:00
    allow id 1d6b:0003 serial "0000:00:0d.0" name "xHCI Host Controller" with-interface 09:00:00
    allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" with-interface 09:00:00
    allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" with-interface 09:00:00
    allow id 06cb:00fc serial "26f9264e7de3" name "" hash "41CoCmCOyBJLNii6ProaAOV9Oduob9jhkrPNj5LBz3k=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface ff:00:00 with-connect-type "not used"
    allow id 04f2:b6ea serial "0001" name "Integrated Camera" hash "odCaanbwFexqJbPU09iCW2UC7QaqEyN3q3BjF7zCdV0=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "not used"
    allow id 8087:0026 serial "" name "" hash "Z5csNGxiUukPPZwSHPyUqpVCNagsfOSSNL2CfXhw4IY=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"
    allow id 1532:008a serial "" name "Razer Viper Mini" hash "gycRexMyR2eGopBOXcvPU/f0DxxE7h6u9RS9aUViBXM=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-1" with-interface { 03:01:02 03:00:01 03:00:01 } with-connect-type "hotplug"
  '';
in
{
  services.pcscd.enable = true;
  services.fprintd.enable = true;

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
  };

  systemIdentity = {
    enable = false;
    pcr15 = "704763c32ce8e3bb53283f8dad0bc2f330f5891fdd7282a8a27de09041e2c2a1";
  };

  services.opensnitch = {
    enable = false;
    rules = {
      systemd-timesyncd = {
        name = "systemd-timesyncd Allow All";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${pkgs.systemd}/lib/systemd/systemd-timesyncd";
        };
      };
      librewolf = {
        name = "Librewolf Allow All";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${userLibrewolf}/lib/librewolf/librewolf";
        };
      };
      routedns = {
        name = "Routedns Allow All";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${pkgs.routedns}/bin/routedns";
        };
      };
      nsncd = {
        name = "nsncd Allow All";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.nsncd}/bin/nsncd";
        };
      };
      networkmanager = {
        name = "NetworkManager Allow All";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.networkmanager}/bin/NetworkManager";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # opensnitch-ui
    yubioath-flutter
    efibootmgr
    sbctl # secure boot
  ];

  services.udev.packages = with pkgs; [ yubikey-personalization ];

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

    # Quickshell lock screen (misc/hm/desktops/hyprland/quickshell/config/Lock.qml).
    # Same as hyprlock: YubiKey challenge-response, then password.
    quickshell-lock = {
      fprintAuth = false;
    };

    # Fingerprint-only service, run in parallel with the one above so the
    # lock screen accepts a finger without blocking the password prompt.
    quickshell-lock-fprint = {
      fprintAuth = true;
      unixAuth = false;
      yubicoAuth = false;
      u2fAuth = false;
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

  # USB device authorization: anything not in the rule set is blocked when
  # plugged in, and quickshell asks what to do
  # (misc/hm/desktops/hyprland/quickshell/config/overlays/UsbPrompt.qml):
  #   Keep blocked / Allow once / Allow always (appends a rule).
  # The rule set is the mutable /var/lib/usbguard/rules.conf (Nix-managed
  # `rules` are read-only, so "Allow always" couldn't save), seeded from
  # usbguardSeedRules above on first start. To bring a learned rule back into
  # Nix: `sudo cat /var/lib/usbguard/rules.conf` and copy it to the seed.
  #
  # The YubiKey isn't in the seed: the first time it's plugged in, pick
  # "Allow always". Until then PAM still accepts the password (yubico and u2f
  # are `sufficient`), so a blocked key can't lock you out.
  services.usbguard = {
    enable = true;
    implicitPolicyTarget = "block";
    presentControllerPolicy = "keep";
    presentDevicePolicy = "apply-policy";
    insertedDevicePolicy = "apply-policy";
    ruleFile = "/var/lib/usbguard/rules.conf";
    # The quickshell prompt runs as this user (`usbguard watch`,
    # `list-devices`, `allow-device`).
    IPCAllowedUsers = [
      "root"
      "orbit"
    ];
  };

  # Seed the rule file instead of the module's empty `touch` (an empty rule
  # set would block the camera, fingerprint reader and Bluetooth at boot).
  systemd.services.usbguard.preStart = lib.mkForce ''
    if [ ! -s /var/lib/usbguard/rules.conf ]; then
      install -D -m 0600 -o root -g root ${usbguardSeedRules} /var/lib/usbguard/rules.conf
    fi
  '';

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
