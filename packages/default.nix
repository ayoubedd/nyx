{ pkgs, ... }:
{
  realod-failed-services = pkgs.callPackage ./reload-failed-services { };
}
