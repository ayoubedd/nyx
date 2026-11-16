{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Text clipboard watcher: `cliphist store` behind a filter that keeps
  # passwords out of the history.
  #
  # - Password managers that mark copies as secret (x-kde-passwordManagerHint,
  #   e.g. KeePassXC): wl-paste sets CLIPBOARD_STATE=sensitive and cliphist
  #   already skips those.
  # - Bitwarden's browser extension can't set that hint (Firefox/LibreWolf
  #   don't support it), so its copies look like any other text. Skip text
  #   that is shaped like a generated password / API key: a single 12-128
  #   character token, no whitespace, not a URL or path, with at least 3 of
  #   lowercase, uppercase, digits and symbols. Such copies still paste
  #   normally; they just aren't kept in the history.
  cliphistStore = pkgs.writeShellScript "cliphist-store-filtered" ''
    if [ "''${CLIPBOARD_STATE:-data}" = data ]; then
      tmp=$(mktemp) || exit 1
      trap 'rm -f "$tmp"' EXIT
      cat > "$tmp"
      size=$(wc -c < "$tmp")
      if [ "$size" -ge 12 ] && [ "$size" -le 130 ] && [ "$(wc -l < "$tmp")" -le 1 ]; then
        s=$(cat "$tmp")
        case "$s" in
          *[[:space:]]* | *://* | /* | '~/'* | ./*) ;;
          *)
            classes=0
            case "$s" in *[a-z]*) classes=$((classes + 1)) ;; esac
            case "$s" in *[A-Z]*) classes=$((classes + 1)) ;; esac
            case "$s" in *[0-9]*) classes=$((classes + 1)) ;; esac
            case "$s" in *[!a-zA-Z0-9]*) classes=$((classes + 1)) ;; esac
            [ "$classes" -ge 3 ] && exit 0
            ;;
        esac
      fi
      exec ${lib.getExe pkgs.cliphist} ${lib.escapeShellArgs config.services.cliphist.extraOptions} store < "$tmp"
    fi
    # sensitive / clear: cliphist handles these (skip / delete the last entry).
    exec ${lib.getExe pkgs.cliphist} ${lib.escapeShellArgs config.services.cliphist.extraOptions} store
  '';

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

  # Launcher (config/launcher/):
  # - clipboard history: cliphist watchers record every copy (text + images);
  #   the launcher lists/decodes/deletes through the cliphist CLI.
  # - wtype sends the paste shortcut after an entry or emoji is picked.
  # - emoji data: built from Unicode's emoji-test.txt + CLDR keywords into
  #   ~/.local/share/nyx/emoji.json (see emoji/build.py).
  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  # Text watcher through the password filter above (images keep the stock
  # `wl-paste --type image --watch cliphist store` service).
  systemd.user.services.cliphist.Service.ExecStart =
    lib.mkForce "${pkgs.wl-clipboard}/bin/wl-paste --watch ${cliphistStore}";
  home.packages = [
    pkgs.cliphist
    pkgs.wtype
    # Privacy indicator: inotifywait watches /dev/video* opens, to spot apps
    # using the camera directly (not through PipeWire).
    pkgs.inotify-tools
    # Screen recording (services/Recorder.qml) and its "Open" notification.
    pkgs.wf-recorder
    pkgs.libnotify
  ];
  xdg.dataFile."nyx/emoji.json".source =
    pkgs.runCommand "nyx-emoji.json" { nativeBuildInputs = [ pkgs.python3 ]; } ''
      python3 ${./emoji/build.py} \
        ${pkgs.unicode-emoji}/share/unicode/emoji/emoji-test.txt \
        ${pkgs.cldr-annotations}/share/unicode/cldr/common \
        $out
    '';

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
