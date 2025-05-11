{ ... }: {
  nix = {
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      download-buffer-size = 524288000;
      sandbox = true;

      auto-optimise-store = true;
      experimental-features =
        [ "nix-command" "flakes" "read-only-local-store" ];

      trusted-users = [ "@wheel" ];

      warn-dirty = false;

      substituters =
        [ "https://hyprland.cachix.org" "https://devenv.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };
}
