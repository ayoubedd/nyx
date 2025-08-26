{ pkgs, ... }:
{
  users.mutableUsers = false;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
