{ ... }: {
  programs.codex = {
    enable = true;

    skills = {
      skill-creator = ./skills/skill-creator.md;
      seo-optimizer = ./skills/seo-optimizer.md;
      ripgrep = ./skills/ripgrep.md;
    };
  };
}
