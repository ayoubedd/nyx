BIULD_OUT="$(
nix repl --quiet 2>/dev/null <<EOL
:lf .
:b outputs.nixosConfigurations.x1.config.programs.hyprland.package
EOL
)"

HYPRLAND_PATH="$(grep -E "out.*/nix/store|/nix/store.*out" <<< "$BIULD_OUT" | awk -F '->' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

LUARC="{
  \"workspace\": {
    \"library\": [
      \"$HYPRLAND_PATH/share/hypr/stubs\"
    ]
  }
}"

cat > ./misc/hm/desktops/hyprland/.luarc.json <<<"$LUARC"
