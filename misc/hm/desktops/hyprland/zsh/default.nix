{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    eza
    gnutar
    unrar
    unzip
    p7zip
    bzip2
    zoxide
    atuin
    poppler
    fd
    ripgrep
    resvg
    imagemagickBig
    fzf
    jq
    direnv
    atool
  ];

  programs.zsh.enable = true;

  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        sort_by = "natural";
      };
    };
  };

  home.sessionVariables = {
    ZDOTDIR = "$HOME/.config/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };

  # Compiled copies of the files above would shadow them forever: they link
  # into the nix store (dated 1970), so a .zwc always looks newer than its
  # source. .zshrc no longer compiles them; this clears any left over.
  home.activation.zshDropStaleZwc = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -f "$HOME"/.config/zsh/.z{shrc,shenv,profile}.zwc{,.old} \
      "$HOME"/.config/zsh/conf.d/*.zwc{,.old}
  '';
}
