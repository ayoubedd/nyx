//@ pragma UseQApplication
// Icon theme for tray/notification/menu icons. Quickshell is Qt 6 and the
// session's QT_QPA_PLATFORMTHEME=qt5ct can't supply one, so without this it
// falls back to hicolor (apps' old bundled icons). Keep in sync with
// gtk.iconTheme in ../../theming.nix. Read at startup only (restart, not reload).
//@ pragma IconTheme Colloid-Grey-Dark
import Quickshell

ShellRoot {
    Bar {}
    NotificationPopups {}
    ControlCenter {}
    Lock {}
    Osd {}
    PolkitDialog {}
    Screenshot {}
    Overview {}
    NowPlayingToast {}
}
