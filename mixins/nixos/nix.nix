{ ... }: {
  nix = {
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      sandbox = true;

      experimental-features =
        [ "nix-command" "flakes" "read-only-local-store" ];

      trusted-users = [ "@wheel" ];

      warn-dirty = false;
    };
  };
}
