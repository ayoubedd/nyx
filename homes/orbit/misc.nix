{ pkgs, ... }: {
  orbit-nvim.enable = true;
  orbit-nvim.neovide = true;

  programs.direnv.enable = true;

  programs.ssh = {
    enable = true;
    compression = true;
    forwardAgent = true;

    extraConfig = ''
      Host github.com
          Hostname ssh.github.com
          Port 443
          User git
    '';
  };

  programs.gh = {
    enable = true;
    extensions = with pkgs; [ gh-markdown-preview ];
    settings = {
      git_protocol = "ssh";
      version = 1;
      editor = "";
      prompt = "enabled";
      pager = "";
      aliases = { co = "pr checkout"; };
      http_unix_socket = "";
      browser = "";
    };
  };

  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" ];
  };

  home.file.".config/atuin/config.toml" = {
    enable = true;
    force = true;
    text = ''
      keymap_mode="vim-insert"
      enter_accept=false
    '';
  };

  home.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
