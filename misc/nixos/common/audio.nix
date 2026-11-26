{ pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    pipewire
    wireplumber
    pavucontrol
    pamixer
    playerctl
  ];
}
