{ ... }: {
  programs.nwg-piotr = {
    enable = true;

    config = [
      {
        label = "Lock";
        exec = "loginctl lock-session self";
        icon = builtins.toString ./images/system-lock-screen.svg;
      }
      {
        label = "Logout";
        exec = "loginctl kill-session self";
        icon = builtins.toString ./images/system-log-out.svg;
      }
      {
        label = "Suspend";
        exec = "systemctl -i suspend";
        icon = builtins.toString ./images/system-suspend.svg;
      }
      {
        label = "Shutdown";
        exec = "systemctl -i poweroff";
        icon = builtins.toString ./images/system-shutdown.svg;
      }
      {
        label = "Reboot";
        exec = "systemctl -i reboot";
        icon = builtins.toString ./images/system-reboot.svg;
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
