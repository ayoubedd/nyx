{ ... }: {
  programs.imv = {
    enable = true;
    settings = {
      options = {
        recursively = true;
        fullscreen =true;
      };
    };
  };
}
