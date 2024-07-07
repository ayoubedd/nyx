{ ... }:
let
    lock-screen-icon = builtins.toString ../../../../../media/icons/system-lock-screen.svg;
    logout-icon = builtins.toString ../../../../../media/icons/system-log-out.svg;
    suspend-icon = builtins.toString ../../../../../media/icons/system-suspend.svg;
    shutdown-icon = builtins.toString ../../../../../media/icons/system-shutdown.svg;
    reboot-icon = builtins.toString ../../../../../media/icons/system-reboot.svg;
in 
{
  programs.nwg-piotr = {
    enable = true;

    config = [
      {
        label = "Lock";
        exec = "loginctl lock-session self";
        icon = lock-screen-icon;
      }
      {
        label = "Logout";
        exec = "loginctl kill-session self";
        icon = logout-icon;
      }
      {
        label = "Suspend";
        exec = "systemctl -i suspend";
        icon = suspend-icon;
      }
      {
        label = "Shutdown";
        exec = "systemctl -i poweroff";
        icon = shutdown-icon;
      }
      {
        label = "Reboot";
        exec = "systemctl -i reboot";
        icon = reboot-icon;
      }
    ];

    style = ''
      window {
              background-color: rgba (0, 0, 0, 1.0);
              border-radius: 5px;
      }

      /* Outer bar container, takes all the window width/height */
      #outer-box {
      	margin: 0px
      }

      /* Inner bar container, surrounds buttons */
      #inner-box {
      	background-color: rgba (0, 0, 0, 0.85);
      	border-radius: 10px;
      	border-style: none;
      	border-width: 1px;
      	border-color: rgba (156, 142, 122, 0.7);
      	padding: 5px;
      	margin: 5px
      }

      button, image {
      	background: none;
      	border: none;
      	box-shadow: none
      }

      button {
      	padding-left: 10px;
      	padding-right: 10px;
      	margin: 5px
      }

      button:hover {
      	background-color: rgba (255, 255, 255, 0.1)
      }
    '';
  };
}
