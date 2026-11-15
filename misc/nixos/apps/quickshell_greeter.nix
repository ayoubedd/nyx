# greetd login screen drawn by Quickshell (./quickshell-greeter), styled like
# the desktop lock screen. Runs inside cage (minimal kiosk compositor) as the
# `greeter` user.
#
# Safety: if the Quickshell greeter fails *before* launching a session (crash,
# compositor error), the wrapper falls back to tuigreet, the previous text
# greeter. TTY logins (Ctrl+Alt+F2…) are unaffected either way.
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Shown by default (still editable on the login screen).
  defaultUser = "orbit";

  # Sessions offered by the picker: every installed Wayland session (same
  # list tuigreet used). Default: the uwsm-managed Hyprland one.
  sessionsDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  defaultSessionName = "Hyprland (uwsm-managed)";
  # Fallback if the session list can't be read.
  sessionCommand = [
    "${config.programs.uwsm.package}/bin/uwsm"
    "start"
    "-e"
    "-D"
    "Hyprland"
    "hyprland.desktop"
  ];

  # Remembers the last chosen session (writable by the greeter user).
  stateDir = "/var/cache/nyx-greeter";

  # The greeter user can't read anything in /home, so the wallpaper and the
  # shared Theme/Icon components are copied into the store.
  # Same picture as the lock screen (~/Pictures/Wallpapers/lockscreen.png,
  # copied into the repo since the greeter can't read /home).
  wallpaper = ../../../assets/images/wallpapers/lockscreen.png;
  shellConfig = ../../hm/desktops/hyprland/quickshell/config;

  greeterConfig = pkgs.runCommand "nyx-quickshell-greeter" { } ''
    mkdir -p $out
    cp ${./quickshell-greeter}/*.qml $out/
    cp ${shellConfig + "/common/Theme.qml"} $out/Theme.qml
    cp ${shellConfig + "/common/Icon.qml"} $out/Icon.qml
  '';

  # Same cursor as the desktop (gtk.cursorTheme / stylix in theming.nix).
  cursorPackage = pkgs.volantes-cursors;
  cursorTheme = "volantes_cursors";
  cursorSize = "24";

  tuigreet = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks -g 'FREE AS IN FREEDOM'";

  greeter = pkgs.writeShellScript "nyx-greeter" ''
    export NYX_GREETER_USER=${lib.escapeShellArg defaultUser}
    export NYX_GREETER_SESSION=${lib.escapeShellArg (builtins.toJSON sessionCommand)}
    export NYX_GREETER_SESSION_NAME=${lib.escapeShellArg defaultSessionName}
    export NYX_GREETER_SESSIONS_DIR=${sessionsDir}
    export NYX_GREETER_STATE=${stateDir}
    export NYX_GREETER_WALLPAPER=${wallpaper}
    export XDG_CACHE_HOME=/tmp/nyx-greeter-cache
    # cage draws no decorations, so Qt would add its own title bar.
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    # Same cursor as the desktop (cage and the greeter both read these).
    export XCURSOR_PATH=${cursorPackage}/share/icons
    export XCURSOR_THEME=${cursorTheme}
    export XCURSOR_SIZE=${cursorSize}

    # The greeter touches this right before handing the session to greetd.
    # cage can crash on its way out after that (segfault in libwayland-server
    # when the client quits), which must not trigger the fallback.
    export NYX_GREETER_LAUNCHED="''${XDG_RUNTIME_DIR:-/tmp}/nyx-greeter-launched"
    rm -f "$NYX_GREETER_LAUNCHED"

    # -s: allow VT switching; -m last: use the last-connected output.
    ${pkgs.cage}/bin/cage -s -m last -- \
      ${pkgs.quickshell}/bin/quickshell -p ${greeterConfig}
    status=$?

    if [ "$status" -eq 0 ] || [ -e "$NYX_GREETER_LAUNCHED" ]; then
      rm -f "$NYX_GREETER_LAUNCHED"
      exit 0
    fi

    echo "nyx-greeter: quickshell greeter failed (exit $status), falling back to tuigreet" >&2
    exec ${tuigreet}
  '';
in
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${greeter}";
      user = "greeter";
    };
  };

  systemd.tmpfiles.rules = [ "d ${stateDir} 0755 greeter greeter -" ];

  # The greeter runs outside the user's session, so its fonts must be
  # system-wide (Theme.qml: Noto Sans + Material Symbols icons).
  fonts.packages = with pkgs; [
    noto-fonts
    material-symbols
  ];
}
