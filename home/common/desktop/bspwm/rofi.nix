{ config, ... }: 
let
  inherit (config.colorscheme) colors;
in {
  programs.rofi = {
    enable = true;
    font = "monospace;2";
    location = "center";
    plugins = [ ];
    terminal = "alacritty";
    theme = "base16-theme";
  };

  xdg.configFile."rofi/base16-theme.rasi".text = ''
      * {
        /* Theme colors */
        theme-foreground:              #${colors.base05};
        theme-foreground-alt:          #${colors.base06};
        theme-background:              #${colors.base00};
        theme-background-alt:          #${colors.base01};
        theme-background-sel:          #${colors.base02};
        theme-background-urg:          #${colors.base08};
        theme-background-urg-sel:      #${colors.base08};
        theme-background-act:          #${colors.base03};
        theme-background-act-sel:      #${colors.base07};
        theme-border:                  #${colors.base0A};
      }
    '' + builtins.readFile ./theme.rasi;
}
