{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # gns3-server
    gns3-gui
    inetutils
    tigervnc
    wireshark
  ];

  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };
}
