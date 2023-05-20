{ config, ... }: 
let
  inherit (config.colorscheme) colors;
in {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 400;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 0;
        foreground = "#${colors.base05}";
        background = "#${colors.base00}";
        frame_color = "#${colors.base07}";
        font = "monospace;2";
        fullscreen = "pushback";
        separator_color = "#${colors.base03}";
      };

      urgency_low = {
        timeout = 3;
      };

      urgency_normal = {
        highlight = "#${colors.base0A}";
        timeout = 5;
      };

      urgency_critical = {
        frame_color = "#${colors.base08}";
        highlight = "#${colors.base08}";
        timeout = 10;
        fullscreen = "show";
      };
    };
  };
}
