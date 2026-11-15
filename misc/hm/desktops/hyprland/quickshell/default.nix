{ config, pkgs, ... }:
let
  # Symlink the config straight to the repo checkout (not the nix store) so
  # quickshell's hot-reload picks up edits without a rebuild.
  # NOTE: assumes the repo is cloned at this path.
  repo = "${config.home.homeDirectory}/Projects/Code/me/nyx";
  shellDir = "${repo}/misc/hm/desktops/hyprland/quickshell/config";
in
{
  programs.quickshell = {
    enable = true;

    # Lands at ~/.config/quickshell/nyx -> run with `qs -c nyx`
    configs.nyx = config.lib.file.mkOutOfStoreSymlink shellDir;
    activeConfig = "nyx";

    # Bar + notification daemon, started with the graphical session.
    systemd.enable = true;
  };

  # Stop with the session instead of being restarted (Restart=on-failure) into
  # a dead Wayland display on logout, which crashed it ("no Qt platform plugin").
  systemd.user.services.quickshell.Unit.PartOf = [ config.wayland.systemd.target ];

  # Bluetooth pairing agent (blueman-applet used to be it). Without an agent
  # BlueZ can't finish pairing: devices connect without a bond and drop again.
  # quickshell can't be an agent itself, so run bluez-tools' bt-agent.
  # NoInputNoOutput = "Just Works" pairing (no PIN shown/typed): bonds
  # headphones, speakers, mice; phones just ask to confirm on their side. The
  # adapter isn't left pairable, so this doesn't accept pairing initiated by
  # other devices.
  systemd.user.services.bt-agent = {
    Unit = {
      Description = "Bluetooth pairing agent (bt-agent, NoInputNoOutput)";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${pkgs.bluez-tools}/bin/bt-agent --capability=NoInputNoOutput";
      Restart = "on-failure";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  # The bar's Wi-Fi and Bluetooth widgets replace the nm-applet / blueman tray
  # applets. Their packages stay installed (the bar opens nm-connection-editor
  # and blueman-manager), so just hide their system XDG autostart entries for
  # this user: a same-named file with Hidden=true overrides /etc/xdg/autostart.
  xdg.configFile = builtins.listToAttrs (
    map
      (name: {
        name = "autostart/${name}.desktop";
        value.text = ''
          [Desktop Entry]
          Hidden=true
        '';
      })
      [
        "nm-applet"
        "blueman"
      ]
  );
}
