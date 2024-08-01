{ pkgs, ... }:
{
  services.udev.packages = with pkgs; [ numworks-udev-rules ];
}
