{ pkgs, ... }:
{
  programs.direnv.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        compression = true;
        forwardAgent = true;
      };
      "github.com" = {
        HostName = "ssh.github.com";
        port = 443;
        User = "git";
      };
    };
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
      aliases = {
        co = "pr checkout";
      };
      http_unix_socket = "";
      browser = "";
    };
  };

  # services.blueman-applet.enable = true;

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
