{ config, pkgs, ... }:
let
  colors = config.colors;
in
{
  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        normal.family = config.fontProfiles.monospace.family;
        normal.style = "Regular";
        bold.family = config.fontProfiles.monospace.family;
        bold.style = "Bold";
        italic.family = config.fontProfiles.monospace.family;
        italic.style = "Italic";
        bold_italic.family = config.fontProfiles.monospace.family;
        bold_italic.style = "Bold Italic";

        size = if config.variables.isLaptop then 12 else 15;
      };

      window = {
        padding = {
          x = 5;
          y = 5;
        };
        dynamic_padding = false;
        opacity = 1.0;
      };

      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };

      shell = {
        program = "${pkgs.fish}/bin/fish";
      };
      colors = {
        primary = {
          background        = "#${colors.background}";
          foreground        = "#${colors.foreground}";
        };
        cursor = {
          text   = "#${colors.background-selection}";
          cursor = "#${colors.foreground}";
        };
        normal = {
          black   = "#${colors.black}";
          white   = "#${colors.white}";
          red     = "#${colors.red}";
          yellow  = "#${colors.yellow}";
          green   = "#${colors.green}";
          cyan    = "#${colors.cyan}";
          blue    = "#${colors.blue}";
          magenta = "#${colors.purple}";
        };
        bright = {
          black   = "#${colors.black-bright}";
          white   = "#${colors.white-bright}";
          red     = "#${colors.red-bright}";
          yellow  = "#${colors.yellow-bright}";
          green   = "#${colors.green-bright}";
          cyan    = "#${colors.cyan-bright}";
          blue    = "#${colors.blue-bright}";
          magenta = "#${colors.purple-bright}";
        };
      };
    };
  };
}
