{ ... }: {
  home.preferXdgDirectories = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
  };

}
