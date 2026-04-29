# nyx

NixOS + Home-Manager flake for two machines.

## Hardware

| Hostname | Machine                    | CPU       | RAM  | GPU      |
| -------- | -------------------------- | --------- | ---- | -------- |
| `x1`     | Lenovo X1 Carbon (9th Gen) | i7-1165G7 | 32GB | Iris Xe  |
| `kraken` | Custom AMD desktop         | R5 3600   | 32GB | RTX 2060 |

## Screenshots

![Application Launcher](/assets/images/doc/app-launcher.png)
![Editor](/assets/images/doc/editor.png)
![GUI file manager](/assets/images/doc/gui-file-manager_blueman.png)
![TUI file manager](/assets/images/doc/tui-file-manager.png)

## Key Features

- **Window Manager** — Hyprland (Wayland) with vim-style bindings
- **Theming** — Stylix for system-wide colorscheming
- **Shell** — Zsh with atuin, yazi, zoxide
- **Audio** — PipeWire with wireplumber
- **Secrets** — SOPS-encrypted secrets per machine
- **Install** — Disko for declarative disk partitioning + LUKS
- **Development** — Devenv, Neovim

## Install

> **Prerequisite:** The SOPS private key must be available to decrypt credentials during install.

```bash
just prep-disk x1       # Destroy disk, setup partitions, lucks, filesystem and mount partitions
just nix-os-install x1  # Install NixOS
# or
just install-nix x1 # does both steps in one
```

## Project Layout

```
machines/          Per-machine NixOS configs
  x1/              ThinkPad X1 Carbon Gen 9
  kraken/          AMD + NVIDIA desktop
modules/
  nixos/           Shared NixOS modules
  hm/              Shared Home-Manager modules
misc/              Shared configs
  nixos/           System-wide options (audio, bluetooth, networking, power)
  hm/              Desktop configs (Hyprland, terminals, browsers, neovim)
packages/         Custom packages and overlays
secrets/           SOPS-encrypted secrets
assets/            Wallpapers and documentation assets
```

## Structure

- `flake.nix` is the entry point, exporting both NixOS and Home-Manager configurations.
- Machine-specific configs live under `machines/<host>/`, importing shared modules from `misc/`.
- User home configs are in `machines/<host>/users/<user>/`.
- Secrets are encrypted with SOPS (`sops..yaml`), machine key lives in `machines/<host>/sops.nix`.
- Dev convenience via `justfile` (`just upp`, `just prep-disk x1`, etc.).

## Credit

Inspired by the excellent configs of:

- [Misterio77](https://github.com/Misterio77/nix-config)
- [Aylur](https://github.com/Aylur/dotfiles)
- [hlissner](https://github.com/hlissner/dotfiles)
- [wimpysworld](https://github.com/wimpysworld/nix-config)
