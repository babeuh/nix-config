{ config,  ... }:
let
  inherit (config.colorscheme) colors;
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

        size = 15;
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
        program = "${config.home.homeDirectory}/.nix-profile/bin/fish";
      };
      colors = {
        primary = {
          background = "#${colors.base00}";
          foreground = "#${colors.base05}";
        };
        cursor = {
          text = "#${colors.base00}";
          cursor = "#${colors.base05}";
        };
        normal = {
          black = "#${colors.base00}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0E}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base05}";
        };
        bright = {
          black = "#${colors.base03}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0E}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base07}";
        };
        # FIXME: idk how to do this
        /*
        indexed_colors = [
          {index = 16; color = "#${colors.base09}";}
          {index = 17; color = "#${colors.base0F}";}
          {index = 18; color = "#${colors.base01}";}
          {index = 10; color = "#${colors.base02}";}
          {index = 20; color = "#${colors.base04}";}
          {index = 21; color = "#${colors.base06}";}
        ];
        */
      };
    };
  };
}
