{ config, pkgs, ... }: {
  imports = [ 
    ./xidlehook.nix
    ./rofi.nix
    ./sxhkd.nix
    ./bspwm.nix
    ./polybar.nix 
  ];

  home.packages = with pkgs; [ scrot feh ];

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
  };
}
