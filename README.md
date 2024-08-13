# nyx

This is my not overly engineerd nix flake for managing my machines and keeping my sanity.

Explore the reposity take what you like.

## Hardware

Currently i use nix everywhere i can, because it's actually worth it. For the moment i only use of my two primary machines. But i have plans to migrate my homelab to be full nix.

| Hostname | Brand                    | CPU         | RAM  | GPU      | OS  |
| -------- | ------------------------ | ----------- | ---- | -------- | --- |
| `x1`     | Lenovo X1 carbon (gen 9) | i7 11th gen | 32Gb | iris xe  | Nix |
| `kraken` | n/a (custom built)       | R5 3600     | 32Gb | RTX 3060 | Nix |

## Screenshots

![Terminal](/assets/images/doc/primary.png)
![GUI file manager](/assets/images/doc/gui-file-manager.png)
![TUI file manager](/assets/images/doc/tui-file-manager.png)
![Application Launcher](/assets/images/doc/application-launcher.png)

## Sofware

System wide config is managed through nix and nix modules everything else is managed through home-manager. Some configurations still not yet ported to nix. (some of them will never like neovim).

- Terminal: [Alacritty](https://github.com/alacritty/alacritty)
- Terminal multiplexer: [Zellij](https://github.com/zellij-org/zellij)
- Shell: zsh
- Editor: Neovim
- Desktop: Hyprland / Sway
- Browser: Firefox
- Media: [imv](https://sr.ht/~exec64/imv/) + mpv + zathura
- Theme: [Night fox](https://github.com/EdenEast/nightfox.nvim/blob/main/extra/carbonfox/base16.yaml) + [Sylix](https://github.com/danth/stylix) for easy system-wide colorscheming
- Development environments: [Devenv](https://github.com/cachix/devenv) + [Direnv](https://github.com/nix-community/nix-direnv)

## Credit

Special thanks to many of the community members without them this config woudn't be possible. Some of them are:

- [Misterio77](https://github.com/Misterio77/nix-config)
- [Aylur](https://github.com/Aylur/dotfiles)
- [hlissner](https://github.com/hlissner/dotfiles)
- [wimpysworld](https://github.com/wimpysworld/nix-config)
