import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services

// Lock screen using the ext-session-lock protocol: Hyprland keeps the session
// locked even if this process dies.
//
//   qs -c nyx ipc call lock lock      (hypridle's lock_cmd / `loginctl lock-session`)
//
// A flag file in $XDG_RUNTIME_DIR survives a quickshell crash/restart, so the
// restarted instance re-locks (needs misc.allow_session_lock_restore).
Scope {
    id: root

    readonly property string flag: `${Quickshell.env("XDG_RUNTIME_DIR")}/nyx-locked`
    readonly property bool locked: sessionLock.locked

    function lock() {
        if (sessionLock.locked)
            return;
        Ui.closeAll();
        Notifs.centerOpen = false;
        lockContext.reset();
        sessionLock.locked = true;
        lockContext.startFingerprint();
        Quickshell.execDetached(["touch", flag]);
    }

    function unlock() {
        lockContext.stopFingerprint();
        sessionLock.locked = false;
        Quickshell.execDetached(["rm", "-f", flag]);
    }

    WlSessionLock {
        id: sessionLock

        // One surface per monitor.
        WlSessionLockSurface {
            color: Theme.background

            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    LockContext {
        id: lockContext
        onUnlocked: root.unlock()
    }

    // Re-lock after a crash/restart while locked.
    Process {
        running: true
        command: ["test", "-e", root.flag]
        onExited: code => {
            if (code === 0)
                root.lock();
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
        function isLocked(): bool {
            return root.locked;
        }
    }
}
