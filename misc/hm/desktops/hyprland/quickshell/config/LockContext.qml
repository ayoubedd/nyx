import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Authentication state shared by every lock surface (one per monitor).
//
// Two PAM conversations run side by side (machines/x1/security.nix):
//   quickshell-lock        YubiKey challenge-response, then password.
//                          With the key plugged in, Enter on an empty field
//                          unlocks (same as hyprlock did).
//   quickshell-lock-fprint fingerprint only. Listens the whole time the screen
//                          is locked, so a finger works without blocking the
//                          password prompt.
// Whichever succeeds first unlocks.
Scope {
    id: root

    signal unlocked
    signal failed

    // ---- password ----
    property string currentText: ""
    property bool busy: false
    property string error: ""

    // ---- engaged: the user is trying to unlock ----
    // Starts false (clear wallpaper); clicking the avatar or typing engages it
    // (blur + password field). Drops back after a while of no input.
    property bool engaged: false

    function engage() {
        engaged = true;
        idle.restart();
    }

    function disengage() {
        if (busy)
            return;
        engaged = false;
        currentText = "";
        error = "";
        idle.stop();
    }

    onCurrentTextChanged: if (currentText !== "")
        engage()

    Timer {
        id: idle
        interval: 20000
        onTriggered: {
            if (root.currentText === "" && !root.busy)
                root.disengage();
            else
                restart();
        }
    }

    // ---- fingerprint ----
    property bool fingerprintEnrolled: false
    property bool fingerprintWanted: false // true while locked
    // Stays true across the short gaps between retries (no icon flicker).
    readonly property bool fingerprintReady: fingerprintEnrolled && fingerprintWanted && fprintQuickFails < 3
    property string fingerprintMessage: ""
    property real fprintStartedAt: 0
    property int fprintQuickFails: 0

    function reset() {
        currentText = "";
        error = "";
        busy = false;
        engaged = false;
        idle.stop();
        if (pam.active)
            pam.abort();
    }

    function tryUnlock() {
        if (busy)
            return;
        engage();
        busy = true;
        error = "";
        if (!pam.start()) {
            busy = false;
            error = "Couldn't start authentication";
        }
    }

    // Called by Lock.qml when locking/unlocking.
    function startFingerprint() {
        fingerprintWanted = true;
        fprintQuickFails = 0;
        fingerprintMessage = "";
        enrollCheck.running = true; // re-check: fingers may have been (un)enrolled
    }

    function stopFingerprint() {
        fingerprintWanted = false;
        fprintRetry.stop();
        if (fprint.active)
            fprint.abort();
        fingerprintMessage = "";
    }

    function runFingerprint() {
        if (!fingerprintEnrolled || !fingerprintWanted || fprint.active)
            return;
        fprintStartedAt = Date.now();
        if (!fprint.start())
            fingerprintMessage = "";
    }

    function succeed() {
        stopFingerprint();
        if (pam.active)
            pam.abort();
        busy = false;
        currentText = "";
        error = "";
        unlocked();
    }

    // ---- password / YubiKey ----
    PamContext {
        id: pam

        config: "quickshell-lock"

        // pam_unix asks for the password; answer with what was typed.
        onPamMessage: {
            if (responseRequired)
                respond(root.currentText);
        }

        onCompleted: result => {
            root.busy = false;
            root.currentText = "";
            if (result === PamResult.Success) {
                root.succeed();
            } else {
                root.error = result === PamResult.MaxTries ? "Too many attempts" : "Incorrect password";
                root.failed();
            }
        }

        onError: err => {
            root.busy = false;
            root.currentText = "";
            root.error = "Authentication error";
            root.failed();
        }
    }

    // ---- fingerprint ----
    Process {
        id: enrollCheck
        command: ["fprintd-list", Quickshell.env("USER")]
        stdout: StdioCollector {
            onStreamFinished: {
                root.fingerprintEnrolled = /#\d+:/.test(text);
                root.runFingerprint();
            }
        }
    }

    PamContext {
        id: fprint

        config: "quickshell-lock-fprint"

        // pam_fprintd only sends info/error messages ("Place your finger…",
        // "Failed to match fingerprint").
        onPamMessage: {
            if (responseRequired) {
                respond(""); // not expected from pam_fprintd
                return;
            }
            root.fingerprintMessage = message;
            if (messageIsError) {
                root.engage(); // show the message
                root.failed(); // shake
            }
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.succeed();
                return;
            }
            // Timeout or too many mismatches: listen again. Failing instantly
            // means the reader is unusable (busy, unplugged…); give up after a few.
            const quick = Date.now() - root.fprintStartedAt < 1500;
            root.fprintQuickFails = quick ? root.fprintQuickFails + 1 : 0;
            if (root.fprintQuickFails < 3)
                fprintRetry.start();
            else
                root.fingerprintMessage = "";
        }

        onError: err => {
            root.fprintQuickFails += 1;
            if (root.fprintQuickFails < 3)
                fprintRetry.start();
            else
                root.fingerprintMessage = "";
        }
    }

    Timer {
        id: fprintRetry
        interval: 800
        onTriggered: root.runFingerprint()
    }
}
