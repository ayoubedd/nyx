{ pkgs, devenv-root, ... }:

{
  packages = with pkgs; [ stylua nixfmt just sops age just nixfmt disko ];
}
