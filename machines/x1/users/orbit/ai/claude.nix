{ ... }: {
  programs.claude-code = {
    enable = true;
    skills = {
      skill-creator = ./skills/skill-creator.md;
      seo-optimizer = ./skills/seo-optimizer.md;
      ripgrep = ./skills/ripgrep.md;
    };

    lspServers = {
      go = {
        args = [
          "serve"
        ];
        command = "gopls";
        extensionToLanguage = {
          ".go" = "go";
        };
      };
      typescript = {
        args = [
          "--lsp"
          "--stdio"
        ];
        command = "tsc";
        extensionToLanguage = {
          ".js" = "javascript";
          ".jsx" = "javascriptreact";
          ".ts" = "typescript";
          ".tsx" = "typescriptreact";
        };
      };
    };
  };
}
