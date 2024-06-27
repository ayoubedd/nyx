{ ... }: {
  imports = [
    ./nix.nix
    ./networking.nix
    ./bluethooth.nix
    ./services.nix
    ./audio.nix
    ./users.nix
  ];
}
