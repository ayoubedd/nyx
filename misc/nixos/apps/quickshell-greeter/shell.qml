// Quickshell greetd greeter (see ../quickshell_greeter.nix). Runs as the
// `greeter` user inside cage; Theme.qml / Icon.qml are copied in at build time
// from the desktop shell config so both look the same.
import Quickshell

ShellRoot {
    Greeter {}
}
