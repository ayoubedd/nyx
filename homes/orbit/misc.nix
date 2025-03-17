{ pkgs, ... }: {
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
