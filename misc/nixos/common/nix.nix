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

      extra-substituters = [
        "https://vicinae.cachix.org"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      warn-dirty = false;
    };
  };
}
