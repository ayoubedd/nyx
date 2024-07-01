{ ... }: {
  imports = [
    ./nix.nix
    ./networking.nix
    ./bluethooth.nix
    ./services.nix
    ./audio.nix
    ./users.nix
    ./power.nix
  ];

  security.rtkit.enable = true; # For processs niceness and priority adjusment through dbus, used by browsers.
  services.fprintd.enable = true;
}
