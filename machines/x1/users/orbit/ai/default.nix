{ pkgs, ... }: {
  imports = [
    ./claude.nix
    # ./opencode.nix
    # ./codex.nix
  ];

  home.packages = with pkgs; [ herdr ];
}
