{ pkgs, devenv-root, ... }:

{
  packages = with pkgs; [
    tombi
    stylua
    nixfmt
    just
    sops
    age
    just
    nixfmt
    disko
  ];
}
