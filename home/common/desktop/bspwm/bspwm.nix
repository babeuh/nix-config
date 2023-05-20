{ config, ... }: 
let
  inherit (config.colorscheme) colors;
in {
  xsession.windowManager.bspwm = {
    enable = true;
    monitors = {
      # 1: Browser; 2: Media; 3: Media Editors; 4: Text; 8: Communication; 9: Game Launchers; 10: Games;
      DP-0 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
    };
    rules = {
      # class_name:instance_name:name
      "firefox" = {
        desktop = "I";
      };
      "spotify" = {
        desktop = "II";
      };
      "*:*:GNU Image Manipulation Program" = {
        desktop = "III";
      };
      "Logseq" = {
        desktop = "IV";
      };
      "discord" = {
        desktop = "VIII";
      };
      "heroic" = {
        desktop = "IX";
      };
      "Steam" = {
        desktop = "IX";
      };
      "steam_app_0" = {
        desktop = "X";
      };
      # F1 2015
      "steam_app_286570" = {
        desktop = "X";
      };
      # F1 2020
      "steam_app_1080110" = {
        desktop = "X";
      };
    };
    settings = {
      border_width         = 2;
      normal_border_color  = "#${colors.base03}";
      focused_border_color = "#${colors.base05}";
      window_gap           = 12;
      split_ratio          = 0.52;
      borderless_monocle   = true;
      gapless_monocle      = true;
    };
    startupPrograms = [
      "feh --bg-fill --no-fehbg ${config.wallpaper}"
    ];
  };
}
