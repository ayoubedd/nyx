{ pkgs, ... }: {
  home.packages = with pkgs; [
    fzf
    curl
    git
    gnutar
    # unrar
    unzip
    p7zip
    bzip2
    zoxide
    macchina
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
