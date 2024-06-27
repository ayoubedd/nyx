{ pkgs, ... }: {
  programs.neovim.enable = true;

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };

  # GCC required to compile tree-sitter highlight's
  home.packages = with pkgs; [ gcc ];
}
