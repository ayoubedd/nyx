{ pkgs, ... }: {
  programs.neovim = with pkgs; {
    enable = true;
    extraPackages = [ nodejs gcc git cargo tree-sitter ];
  };

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
