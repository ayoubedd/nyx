{ pkgs, ... }:
{
  # Thunar
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  programs.xfconf.enable = true;
  services.tumbler.enable = true;

  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer # Need For Video / Image Preview
  ];
}
