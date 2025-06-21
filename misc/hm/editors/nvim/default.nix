{ pkgs, ... }: {
  home.packages = with pkgs; [ neovide ];

  programs.neovim = {
    enable = true;

    plugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.asm
        p.bash
        p.c
        p.cpp
        p.css
        p.csv
        p.diff
        p.dockerfile
        p.gitattributes
        p.gitcommit
        p.git_config
        p.gitignore
        p.go
        p.goctl
        p.gomod
        p.gosum
        p.html
        p.ini
        p.javascript
        p.jsdoc
        p.json
        p.just
        p.latex
        p.linkerscript
        p.lua
        p.make
        p.markdown
        p.nasm
        p.nginx
        p.objdump
        p.passwd
        p.proto
        p.python
        p.regex
        p.rust
        p.scss
        p.ssh_config
        p.strace
        p.toml
        p.tsx
        p.typescript
        p.udev
        p.vim
        p.vimdoc
        p.vue
        p.xml
        p.yaml
      ]))
    ];

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

      # formatters
      nixfmt
      nodePackages.prettier
      prettierd
      black
      stylua
      rustfmt
    ];
  };

  home.file.".config/nvim" = {
    source = ./conf;
    recursive = true;
  };
}
