{ ... }: {
  programs.nwg-piotr = {
    enable = true;

    config = [
      {
        label = "Lock";
        exec = "swaylock -f -c 000000";
        icon = "/usr/share/nwg-bar/images/system-lock-screen.svg";
      }
      {
        label = "Lock";
        exec = "swaylock -f -c 000000";
        icon = "/usr/share/nwg-bar/images/system-lock-screen.svg";
      }
      {
        label = "Lock";
        exec = "swaylock -f -c 000000";
        icon = "/usr/share/nwg-bar/images/system-lock-screen.svg";
      }
    ];

    style = ''
      window {
              background-color: rgba (0, 0, 0, 1.0)
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
