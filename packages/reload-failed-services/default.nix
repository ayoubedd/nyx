{ writeShellScriptBin }: writeShellScriptBin "reload-failed-services" ''
  systemctl --user list-units --failed | grep -Po '([A-Za-z-0-9]+.service)' | xargs systemctl --user restart
''
