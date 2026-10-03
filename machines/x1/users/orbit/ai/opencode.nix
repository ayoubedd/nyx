{ pkgs, ... }: {
  programs.opencode = {
    enable = true;
    extraPackages = with pkgs; [
      # lsp servers
      nixd
      pyright
      pylint
      rust-analyzer
      gopls
      clang-tools
      bash-language-server
      svelte-language-server
      typescript-language-server
      vscode-langservers-extracted
      lua-language-server
      tailwindcss-language-server
      yaml-language-server
    ];
  };
}
