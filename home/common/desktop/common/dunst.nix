{ config, ... }:
let
  colors = config.colors;
in
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = if config.variables.isLaptop then 200 else 400;
        height = if config.variables.isLaptop then 150 else 300;
        offset = if config.variables.isLaptop then "15x25" else "30x50";
        origin = "top-right";
        font = "monospace " + (if config.variables.isLaptop then "8" else "14");
        fullscreen = "pushback";
        transparency = 0;

        background = "#${colors.background}";
        foreground = "#${colors.foreground}";
        frame_color = "#${colors.foreground-most}";
        separator_color = "#${colors.background-least}";
      };

      urgency_low = {
        timeout = 3;
      };

      urgency_normal = {
        highlight = "#${colors.accent}";
        timeout = 5;
      };

      urgency_critical = {
        frame_color = "#${colors.red}";
        highlight = "#${colors.red}";
        timeout = 10;
        fullscreen = "show";
      };
    };
  };
}
