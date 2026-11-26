//@ pragma UseQApplication
// Icon theme for tray/notification/menu icons. Quickshell is Qt 6 and the
// session's QT_QPA_PLATFORMTHEME=qt5ct can't supply one, so without this it
// falls back to hicolor (apps' old bundled icons). Keep in sync with
// gtk.iconTheme in ../../theming.nix. Read at startup only (restart, not reload).
//@ pragma IconTheme Colloid-Grey-Dark
import Quickshell
import qs.common
import qs.services
import qs.bar
import qs.notifications
import qs.lock
import qs.overlays
import qs.launcher

ShellRoot {
    // Singletons are created on first use. These run from startup but are
    // otherwise only touched from menus, so reference them here.
    readonly property bool bluetoothAutoOff: BluetoothAutoOff.autoOff

    Bar {}
    NotificationPopups {}
    ControlCenter {}
    Lock {}
    Osd {}
    PolkitDialog {}
    Screenshot {}
    Overview {}
    NowPlayingToast {}
    Launcher {}
    PowerSaver {}
    MuteLeds {}
    AutoPause {}
    BrightnessMemory {}
    UsbPrompt {}
    RegisterPanel {}
    AltTab {}
    QrCode {}
    IdleFade {}
}
