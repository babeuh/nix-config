{ config, pkgs, ... }:
let
  colors = config.colors;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "monospace " + (if config.variables.isLaptop then "12" else "16");
    location = "center";
    terminal = "alacritty";
    theme = "base16-theme";
  };

  xdg.configFile."rofi/base16-theme.rasi".text =
    ''
      * {
        /* Theme colors */
        theme-foreground:              #${colors.foreground};
        theme-foreground-alt:          #${colors.foreground-alt};
        theme-background:              #${colors.background};
        theme-background-alt:          #${colors.background};
        theme-background-sel:          #${colors.background-selection};
        theme-background-urg:          #${colors.red};
        theme-background-urg-sel:      #${colors.red};
        theme-background-act:          #${colors.foreground};
        theme-background-act-sel:      #${colors.white};
        theme-border:                  #${colors.accent};
      }
    ''
    + builtins.readFile ./theme.rasi;
}
