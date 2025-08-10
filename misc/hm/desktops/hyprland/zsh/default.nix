{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    git
    gnutar
    unrar
    unzip
    p7zip
    bzip2
    zoxide
    macchina

    atuin

    ueberzugpp

    yazi
    poppler
    fd
    ripgrep
    resvg
    imagemagick
    fzf
    jq
    zoxide
  ];

  programs.zsh.enable = true;

  home.sessionVariables = {
    ZDOTDIR = "$HOME/.config/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };
}
