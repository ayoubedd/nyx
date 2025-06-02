{ inputs, ... }: {
  imports = [
    ./waybar.nix
    ./sway-notification-center.nix
    ./wofi.nix
    ./nwg-piotr.nix
    ./sherlock.nix
    ../../../../../misc/hm/media/imv.nix
  ];
}
