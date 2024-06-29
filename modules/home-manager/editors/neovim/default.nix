{ pkgs, ... }: {
  programs.neovim = with pkgs; {
    enable = true;
    extraPackages = [ nodejs gcc git cargo ];
  };

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
