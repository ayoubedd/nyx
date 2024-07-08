{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./networking.nix
    ./bluethooth.nix
    ./services.nix
    ./audio.nix
    ./users.nix
    ./power.nix
  ];


  programs.nix-ld.enable = true;
  security.rtkit.enable = true; # For processs niceness and priority adjusment through dbus, used by browsers.

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  programs.dconf.enable = true;
}
