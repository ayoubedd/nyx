{ pkgs, lib, ... }:
{
  services.devmon.enable = lib.mkForce false;
  # services.fwupd.enable = true;

  # console = {
  # enable = true;
  # font = "ter-v32b";
  # packages = [ pkgs.terminus_font ];
  # keyMap = "us";
  # };

  # Login screen: greetd + quickshell greeter (falls back to tuigreet),
  # see ../../misc/nixos/apps/quickshell_greeter.nix (imported in ./default.nix).

  # Wi-Fi is handled by the quickshell bar. programs.nm-applet (shared
  # misc/nixos/common/networking.nix) runs nm-applet as a systemd user service,
  # which the autostart override can't hide, so turn it off here. Keep the
  # package for nm-connection-editor ("Network settings" in the bar); its XDG
  # autostart entry is hidden by the home-manager quickshell module.
  programs.nm-applet.enable = lib.mkForce false;
  environment.systemPackages = [ pkgs.networkmanagerapplet ];

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
    magicOrExtension = "\\x7fELF....AI\\x02";
  };

  services.pipewire.wireplumber.extraConfig = {
    "1000-all" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";
            }
            {
              "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI2__sink";
            }
            {
              "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI3__sink";
            }
            {
              "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source";
            }
          ];
          actions = {
            update-props = {
              "node.disabled" = true;
            };
          };
        }
        {
          matches = [
            {
              "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source";
            }
          ];
          actions = {
            update-props = {
              "node.description" = "Laptop Mic";
            };
          };
        }
        {
          matches = [
            {
              "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
            }
          ];
          actions = {
            update-props = {
              "node.description" = "Laptop";
            };
          };
        }
        {
          matches = [
            {
              "device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";
            }
          ];
          actions = {
            update-props = {
              device.description = "Laptop";
              device.nick = "Laptop";
            };
          };
        }
      ];
    };
  };
}
