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
  nix.settings.trusted-substituters = [ "https://devenv.cachix.org" ];
  nix.settings.trusted-public-keys =
    [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
}
