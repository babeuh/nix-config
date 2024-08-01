{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ distrobox ];
}
