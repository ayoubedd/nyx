{ pkgs, ... }: {
  programs.neovim = with pkgs; {
    enable = true;
    extraPackages = [ nodejs gcc git cargo tree-sitter ];
  };

  home.packages = with pkgs; [ neovide ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
