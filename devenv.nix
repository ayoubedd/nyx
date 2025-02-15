{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [ just sops age just ];
}
