alias n := build-switch-nixos
alias h := build-switch-homemanager
alias all := build-switch-nix-and-homemanager

hostname := `hostname`
user := `whoami`

default:
  @just --list

# Build and switch nixos config 
build-switch-nixos machine=hostname:
  sudo nixos-rebuild switch --flake '.#{{ machine }}' 

# Build and switch home-manager config
build-switch-homemanager machine=hostname user=user :
  home-manager switch --flake '.#{{ user }}@{{ machine }}'

build-switch-nix-and-homemanager machine=hostname user=user :
  sudo nixos-rebuild switch --flake '.#{{ machine }}' 
  home-manager switch --flake '.#{{ user }}@{{ machine }}'

# Update all flake inputs
upp:
  nix flake update

# Update target flake input
up *targets:
  nix flake update {{ targets }}

# Garbage collect
gc:
  sudo nix-collect-garbage --delete-old

# Garbage collect
fmt:
  nix fmt
