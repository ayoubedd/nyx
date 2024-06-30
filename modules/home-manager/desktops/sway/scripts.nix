{ ... }: {
  home.file.".local/bin/app_launcher" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      if [ "$(pgrep wofi)" ]
      then
      	exit 1
      fi

      # Run
      wofi
    '';
  };

  home.file.".local/bin/sway_action" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      if [ "$(pgrep wofi)" ]
      then
      	exit 1
      fi

      entries="Lock,Logout,Suspend,Reboot,Shutdown"

      selected=$(echo $entries | tr ',' '\n' | wofi -d -p "Action" | awk '{print tolower($1)}')

      case $selected in
        lock)
          exec swaylock -f;;
        logout)
          swaymsg exit;;
        suspend)
          exec systemd-run --user systemctl suspend;;
        reboot)
          exec systemd-run --user reboot;;
        shutdown)
          exec systemd-run --user poweroff;;
      esac
    '';
  };

  home.file.".local/bin/window_picker" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash


      if [ "$(pgrep wofi)" ]
      then
      	exit 1
      fi

      # Get available windows
      windows=$(swaymsg -t get_tree | jq -r '.nodes[1].nodes[] | .. | (.id|tostring) + " " + .name?' | grep -E "[0-9]+"  )

      # Select window with rofi
      selected=$(echo "$windows" | wofi -dip "Window" | awk '{print $1}')

      if [ "$selected" == "" ]
      then
      	exit 1
      fi

      # Tell sway to focus said window
      swaymsg [con_id="$selected"] focus
    '';
  };
}
