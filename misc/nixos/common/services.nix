{ pkgs, ... }:
{
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    # The only OOM killer (no swap on this system, so act on free RAM before
    # the kernel thrashes the page cache). Names are matched against
    # /proc/<pid>/comm, which Nix wrappers turn into e.g. ".Hyprland-wrapp".
    earlyoom = {
      enable = true;
      extraArgs = [
        "--avoid"
        "^(\\.?Hyprland.*|start-hyprland|\\.?quickshell.*)$"
        "--prefer"
        "^(\\.?electron.*|node)$"
      ];
    };
    dbus.packages = [
      pkgs.gnome-keyring
      pkgs.gcr_4
    ];
  };

  # earlyoom handles OOM; don't run a second killer alongside it.
  systemd.oomd.enable = false;

  services.flatpak.enable = true; # Enable Flatpak
}
