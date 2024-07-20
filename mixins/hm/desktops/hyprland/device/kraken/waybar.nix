{ lib, ... }: {
  programs.waybar = {
    settings = {
      mainBar = {
        "modules-right" = lib.mkForce [ "network" "pulseaudio" "cpu" "memory" "tray" ];
      };
    };

    style = lib.mkForce ''
      * {
          border: none;
          border-radius: 0;
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: Noto Sans;
          font-size: 14px;
          min-height: 24px;
      }

      window#waybar {
          background: #161616;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      #workspaces {
          margin-right: 8px;
          transition: none;
          background: #161616;
      }

      #workspaces button {
          transition: none;
          color: #7c818c;
          background: transparent;
          padding: 5px;
      }

      #workspaces button.persistent {
          color: #7c818c;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button:hover {
          transition: none;
          box-shadow: inherit;
          text-shadow: inherit;
          border-radius: inherit;
          color: #161616;
          background: #7c818c;
      }

      #workspaces button.focused {
          color: white;
      }

      #workspaces button.active {
          transition: none;
          box-shadow: inherit;
          text-shadow: inherit;
          border-radius: inherit;
          color: #161616;
          background: #7c818c;
      }

      #mode {
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #clock {
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #pulseaudio {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #memory {
          padding-left: 5px;
          padding-right: 5px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #backlight {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #battery {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #battery.charging {
          color: #ffffff;
          background-color: #26A65B;
      }

      #battery.warning:not(.charging) {
          background-color: #ffbe61;
          color: black;
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }



      #cpu {
          /* margin-right: 8px; */
          padding-left: 16px;
          padding-right: 5px;
          border-radius: 10px 0 0 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #network {
          margin-right: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #temperature {
          padding-left: 5px;
          padding-right: 5px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      #temperature.critical {
          background-color: #eb4d4b;
      }

      #upower {
          margin-right: 8px;
          padding-left: 5px;
          padding-right: 16px;
          border-radius:  0 10px 10px 0;
          transition: none;
          color: #ffffff;
          background: #161616;
      }



      #tray {
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 10px;
          transition: none;
          color: #ffffff;
          background: #161616;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }
    '';
  };
}
