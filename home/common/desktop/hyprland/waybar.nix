{ inputs, outputs, config, ... }:
let
  inherit (config.colorscheme) colors;
in
{
  programs.waybar = {
    enable = true;
    package = inputs.hyprland.packages.x86_64-linux.waybar-hyprland;
    settings = {
      bar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 12;

        modules-left = [ "wlr/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "hyprland/submap" "disk" "memory" "cpu" "network" "tray" ];

        "wlr/workspaces" = {
          sort-by-name = false;
          sort-by-number = true;
          format = "{name}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
          persistent_workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
          };
        };

        "hyprland/window" = {
          format = "{}";
          seperate-outputs = true;
        };

        "clock" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          format-us = "us";
          tooltip = true;
          tooltip-format = "{:%Y-%m-%d}";
        };

        "disk" = {
          interval = 30;
          format = "DISK {percentage_used}%";
          path = "/";
        };

        "memory" = {
          interval = 5;
          format = "RAM {used:0.1f}G";
        };

        "cpu" = {
          inverval = 5;
          format = "CPU {usage}%";
        };

        "network" = {
          format = "{ifname}";
          format-ethernet = "{ipaddr}";
          format-wifi = "WI-FI ({signalStrength}%)";
          format-disconnected = "N/A";
          tooltip = true;
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-ethernet = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid}";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };

        "tray" = {
          icon-size = 21;
          spacing = 4;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: CozetteVector;
        font-size: 20px;
        min-height: 0;
        color: #${colors.base05};
        text-shadow: rgba(0,0,0,0);
      }

      window#waybar {
        background: #${colors.base00};
        color: #${colors.base05};
      }

      tooltip {
        background: #${colors.base01}
      }

      tooltip label {
        color: #${colors.base04};
      }
    '';
  };
}
