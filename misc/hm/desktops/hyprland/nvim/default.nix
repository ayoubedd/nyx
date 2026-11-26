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
      emmylua-ls
      kdePackages.qtdeclarative # qmlls (quickshell)

      # lsp servers
      # (lua: emmylua-ls above; TypeScript: the `typescript` package's
      # native tsc server, below; eslint: vscode-langservers-extracted)
      helm-ls
      nixd
      pyright
      rust-analyzer
      gopls
      clang-tools
      typos-lsp
      bash-language-server
      shellcheck # used by bash-language-server
      svelte-language-server
      vscode-langservers-extracted
      css-variables-language-server
      emmet-ls
      harper
      tailwindcss-language-server
      yaml-language-server
      tofu-ls
      docker-language-server
      marksman
      taplo

      # formatters
      nixfmt
      prettier
      prettierd
      black
      stylua
      rustfmt
      typescript
    ];
  };

  home.file.".config/nvim" = {
    source = ./conf;
    recursive = true;
  };
}
