{ ... }:
{
  nixpkgs.config.allowUnfree = true;

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
      experimental-features = [
        "nix-command"
        "flakes"
        "read-only-local-store"
      ];

      trusted-users = [ "@wheel" ];

      warn-dirty = false;
    };
  };
}
