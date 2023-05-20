{ config, pkgs, lib, ... }:

let 
  inherit (config.colorscheme) colors;
  settings = {
    openasar = {
      setup = true;
      noTyping = true;
    };
    SKIP_HOST_UPDATE = true;
    MINIMIZE_TO_TRAY = false;
    IS_MAXIMIZED = false;
    IS_MINIMIZED = false;
  };
in {
  home.packages = with pkgs; [ discord ];

  xdg.configFile."discord/settings.json".text = (builtins.toJSON settings);
}
