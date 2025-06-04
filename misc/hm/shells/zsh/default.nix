{ pkgs, ... }: {
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

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };
}
