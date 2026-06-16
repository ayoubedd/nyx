{ pkgs, ... }:
{
  programs.neovide.enable = true;

  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      # essentials
      nodejs
      gcc
      git
      cargo
      gnumake # telescope-fzf-native-nvim
      tree-sitter
      ripgrep
      inotify-tools

      # lsp servers
      nixd
      pyright
      eslint_d
      pylint
      rust-analyzer
      gopls
      clang-tools
      typos-lsp
      bash-language-server
      svelte-language-server
      typescript-language-server
      vscode-langservers-extracted
      emmet-ls
      harper
      lua-language-server
      tailwindcss-language-server
      yaml-language-server
      deno

      # formatters
      nixfmt
      prettier
      prettierd
      black
      stylua
      rustfmt
      typescript-go
    ];
  };

  home.file.".config/nvim" = {
    source = ./conf;
    recursive = true;
  };
}
