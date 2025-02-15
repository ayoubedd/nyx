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

  home.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
