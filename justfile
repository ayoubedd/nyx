alias build := build-switch-nixos
alias b := build-switch-nixos

hostname := `hostname`
user := `whoami`
cwd := `pwd`

# Documentation
default:
  @just --list

# Build and switch nixos config 
build-switch-nixos machine=hostname:
  sudo nixos-rebuild switch --flake '.#{{ machine }}' 

# Update all flake inputs
upp:
  nix flake update

# Update target flake input
up *targets:
  nix flake update {{ targets }}

# Garbage collect
gc:
  nix-env -u --always
  sudo rm /nix/var/nix/gcroots/auto/*
  nix-collect-garbage --delete-old
  sudo nix-collect-garbage --delete-old

# Format all files
fmt:
  nix fmt

# Crate a symbolic link from nvim source config directly to config diretory (for dev)
videv:
  rm -rf ~/.config/nvim
  ln -sf '{{ cwd }}'/misc/hm/desktops/hyprland/nvim/conf ~/.config/nvim

# Remove dev symbolic link
viclean:
  rm -rf ~/.config/nvim

# Prepare machine disk for a nix fresh install
prep-disk machine:
  sudo disko --flake '.#{{ machine }}' --mode destroy,format,mount --root-mountpoint /mnt

# Install nixos
nix-os-install machine:
  sudo nixos-install --flake '.#{{ machine }}' --root /mnt

# Format disk and install nixos on target machine
install-nix machine:
  @just prep-disk '{{ machine }}'
  @just nix-os-install '{{ machine }}'


build-iso name:
  nix build ".#nixosConfigurations.isos.{{ name }}.config.system.build.isoImage"

run-iso:
  qemu-system-x86_64 -cpu host -smp $(nproc) -m 8G -machine type=q35,accel=kvm \
    -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 \
    -device virtio-vga-gl -display sdl,gl=on \
    -cdrom result/iso/*.iso

sh:
  nix develop --command $SHELL

# Create hashed password
mkpasswd:
  mkpasswd -R 10000 -m sha-512
