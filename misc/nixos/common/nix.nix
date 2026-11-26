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

      experimental-features = [
        "nix-command"
        "flakes"
        "read-only-local-store"
      ];

      trusted-users = [ "@wheel" ];

      # Binary cache for the CachyOS kernel (nix-cachyos-kernel). The flake's
      # nixConfig only reaches users who accept it; root's `nixos-rebuild`
      # ignores it, which would compile the LTO kernel locally.
      substituters = [ "https://cache.lantian.pub/lantian" ];
      trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];

      warn-dirty = false;
    };
  };
}
