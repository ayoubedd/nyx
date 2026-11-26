{
  config,
  pkgs,
  ...
}:
let
  # Mic noise suppression (services/NoiseSuppression.qml): an RNNoise
  # PipeWire filter reading the given mic and offering a virtual source,
  # "Noise-suppressed mic" (node nyx_rnnoise_source). It lives exactly as
  # long as this process (the module is loaded into pw-cli), so quickshell
  # starts/stops it with the sound menu switch. The capture side is passive:
  # the real mic only opens while an app records from the virtual one.
  #   nyx-noise-suppression <mic node.name>
  nyxNoiseSuppression = pkgs.writeShellScriptBin "nyx-noise-suppression" ''
    [ -n "''${1:-}" ] || { echo "usage: nyx-noise-suppression <mic node.name>" >&2; exit 2; }
    exec ${pkgs.pipewire}/bin/pw-cli -m load-module libpipewire-module-filter-chain "{
      node.description = \"Noise-suppressed mic\"
      media.name = \"Noise-suppressed mic\"
      filter.graph = {
        nodes = [ {
          type = ladspa
          name = rnnoise
          plugin = \"${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so\"
          label = noise_suppressor_mono
          control = {
            \"VAD Threshold (%)\" = 50.0
            \"VAD Grace Period (ms)\" = 200
            \"Retroactive VAD Grace (ms)\" = 0
          }
        } ]
      }
      capture.props = {
        node.name = \"capture.nyx_rnnoise\"
        node.passive = true
        audio.rate = 48000
        target.object = \"$1\"
      }
      playback.props = {
        node.name = \"nyx_rnnoise_source\"
        media.class = Audio/Source
        audio.rate = 48000
      }
    }"
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
  # Clipboard history in RAM only: cliphist's database lives in the runtime
  # dir (tmpfs, cleared at logout/shutdown; no swap here), never on disk.
  # cliphist reads CLIPHIST_<FLAG> env vars, so every user of it needs this:
  # the two watchers, quickshell (launcher, register panel) and shells.
  # (%t = $XDG_RUNTIME_DIR in systemd units.) Registers live there too
  # (services/Registers.qml).
  systemd.user.services.cliphist.Service.Environment = [ "CLIPHIST_DB_PATH=%t/cliphist.db" ];
  systemd.user.services.cliphist-images.Service.Environment = [ "CLIPHIST_DB_PATH=%t/cliphist.db" ];
  systemd.user.services.quickshell.Service.Environment = [ "CLIPHIST_DB_PATH=%t/cliphist.db" ];
  home.sessionVariables.CLIPHIST_DB_PATH = "$XDG_RUNTIME_DIR/cliphist.db";
  home.packages = [
    pkgs.cliphist
    pkgs.wtype
    # Privacy indicator: inotifywait watches /dev/video* opens, to spot apps
    # using the camera directly (not through PipeWire).
    pkgs.inotify-tools
    # Screen recording (services/Recorder.qml) and its "Open" notification.
    pkgs.wf-recorder
    pkgs.libnotify
    nyxNoiseSuppression
    # Screenshot tool "Text" (OCR) and "QR" (scan) actions, and the QR code
    # panel (overlays/QrCode.qml).
    (pkgs.tesseract.override {
      enableLanguages = [
        "eng"
        "fra"
        "ara"
      ];
    })
    pkgs.zbar
    pkgs.qrencode
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
