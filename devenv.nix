{ pkgs, devenv-root, ... }:

{
  packages = with pkgs; [ just sops age just ];
}
