{ pkgs, outputs, config, ... }:
let
  inherit (config.colorscheme) colors;
  waybar-mullvad = pkgs.writeShellScriptBin "waybar-mullvad" ''
    ## [Set VPN commands]. Setup for Mullvad is done below.
    # The first three commands should have direct equivalents for most VPNs.
    # The relay_set command assumes <country_code> <city_code> will follow as arguments. See below.
    VPN_CONNECT="${pkgs.mullvad-vpn}/bin/mullvad connect"
    VPN_DISCONNECT="${pkgs.mullvad-vpn}/bin/mullvad disconnect"
    VPN_GET_STATUS="${pkgs.mullvad-vpn}/bin/mullvad status"
    VPN_ENTRY_SET_LOCATION="${pkgs.mullvad-vpn}/bin/mullvad relay set tunnel wireguard --entry-location"
    VPN_RELAY_SET_LOCATION="${pkgs.mullvad-vpn}/bin/mullvad relay set location"

    ## [Set VPN status parsing]
    # The first command cuts the status, which is compared to keywords below.
    # It's made to be fairly generic to apply across VPNs.
    VPN_STATUS="$($VPN_GET_STATUS | ${pkgs.gnugrep}/bin/grep -Eio 'connected|connecting|disconnect' | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')"
    CONNECTED="connected"
    CONNECTING="connecting"

    # Icons glyphs should be given by most Nerd Fonts (https://www.nerdfonts.com/cheat-sheet)
    ICON_CONNECTED=""
    ICON_CONNECTING=""
    ICON_DISCONNECTED=""
    COLOR_CONNECTED="#${colors.base0B}"
    COLOR_CONNECTING="#${colors.base0A}"
    COLOR_DISCONNECTED="#${colors.base08}"

    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ## Main Script

    DIRNAME="${config.home.homeDirectory}/.cache/waybar/mullvad"
    mkdir -p $DIRNAME
    ${pkgs.mullvad-vpn}/bin/mullvad relay list | ${pkgs.gnused}/bin/sed "/\s*..-...-.*-/d" | sed "/^\$/d" > "$DIRNAME"/raw
    cat "$DIRNAME"/raw | ${pkgs.coreutils}/bin/cut -d "(" -f 1 | ${pkgs.gnused}/bin/sed "s/\t/ - /g" > "$DIRNAME"/locations
    cat "$DIRNAME"/raw | ${pkgs.gawk}/bin/awk '/^[[:alnum:]]/ {prefix = $0; print; next} {print prefix $0}' | ${pkgs.gawk}/bin/awk -F"[()]" '{print $2 " " $4}' > "$DIRNAME"/codes

    mapfile -t VPN_LOCATIONS < "$DIRNAME"/locations
    mapfile -t VPN_CODES < "$DIRNAME"/codes

    ip_address_lookup() {
      ip_address=$(${pkgs.mullvad-vpn}/bin/mullvad status -v | head -n 1 | ${pkgs.gawk}/bin/awk 'match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/){print substr($0,RSTART,RLENGTH)}')
      if [ -z "$ip_address" ]; then
        ip_address=""
      fi
      echo "$ip_address"
    }

    vpn_report() {
      mullvad status listen | while read -r line; do
        VPN_STATUS="$(echo $line | ${pkgs.gnugrep}/bin/grep -Eio 'connected|connecting|disconnect' | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')"
        if [ "$VPN_STATUS" = "$CONNECTED"  ]; then
          report="$(echo $line | ${pkgs.gnused}/bin/sed -n 's/.*in //p')"
          printf '{"text": "%s", "tooltip": "Connected to %s", "class": "connected"}\n' "$ICON_CONNECTED" "$report"
        elif [ "$VPN_STATUS" = "$CONNECTING" ]; then
          report="$(echo $line | ${pkgs.gnused}/bin/sed -n 's/.*in //p')"
          printf '{"text": "%s", "tooltip": "Connecting to %s", "class": "connecting"}\n' "$ICON_CONNECTING" "$report"
        else
          printf '{"text": "%s", "tooltip": "Disconnected", "class": "disconnected"}\n' "$ICON_DISCONNECTED"
        fi
        sleep 2
      done
    }


    vpn_toggle_connection() {
    # connects or disconnects vpn
        if [ "$VPN_STATUS" = "$CONNECTED" ]; then
            $VPN_DISCONNECT
        else
            $VPN_CONNECT
        fi
    }


    vpn_location_menu() {
    # TODO: size with laptop
      ENTRY="$(${pkgs.rofi-wayland}/bin/rofi -location 3 -theme-str "window { height: 250px; width: 250px; x-offset: -272px; y-offset: 10px; }" -sep "\n" -dmenu -i -p "Mullvad VPN Entry" -input "$DIRNAME"/locations)"
      EXIT="$(${pkgs.rofi-wayland}/bin/rofi -location 3 -theme-str "window { height: 250px; width: 250px; x-offset: -272px; y-offset: 10px; }" -sep "\n" -dmenu -i -p "Mullvad VPN Exit" -input "$DIRNAME"/locations)"

      if [ "$ENTRY" != "" ]; then
        for i in "''${!VPN_LOCATIONS[@]}"; do
          if [ "''${ENTRY}" = "''${VPN_LOCATIONS[$i]}" ]; then
            $VPN_ENTRY_SET_LOCATION ''${VPN_CODES[$i]} >/dev/null 2>&1;
          fi
        done
      fi

      if [ "$EXIT" != "" ]; then
        for i in "''${!VPN_LOCATIONS[@]}"; do
          if [ "''${EXIT}" = "''${VPN_LOCATIONS[$i]}" ]; then
            $VPN_RELAY_SET_LOCATION ''${VPN_CODES[$i]} >/dev/null 2>&1;
          fi
        done
      fi

      if [ "$VPN_STATUS" = "$CONNECTED" ] || [ "$ENTRY" == "" ] || [ "$EXIT" == "" ]; then
            return
        else
            $VPN_CONNECT
      fi
    }


    ip_address_to_clipboard() {
    # finds your IP and copies to clipboard
      ip_address=$(ip_address_lookup)
      if [ "$ip_address" != "" ]; then
        echo $ip_address | ${pkgs.wl-clipboard}/bin/wl-copy -n
      fi
    }


    case "$1" in
      toggle|--toggle-connection) vpn_toggle_connection ;;
      menu|--location-menu) vpn_location_menu ;;
      ip-clip|--ip-address) ip_address_to_clipboard ;;
      status) vpn_report ;;
    esac
  '';

  waybar-yubikey = pkgs.writeShellScriptBin "waybar-yubikey" ''
    socket="''${XDG_RUNTIME_DIR:-/run/user/$UID}/yubikey-touch-detector.socket"

    while true; do
        touch_reasons=()

        if [ ! -e "$socket" ]; then
            printf '{"text": "Waiting for YubiKey socket"}\n'
            while [ ! -e "$socket" ]; do sleep 1; done
        fi
        printf '{"text": ""}\n'

        nc -U "$socket" | while read -n5 cmd; do
            reason="''${cmd:0:3}"

            if [ "''${cmd:4:1}" = "1" ]; then
                touch_reasons+=("$reason")
            else
                for i in "''${!touch_reasons[@]}"; do
                    if [ "''${touch_reasons[i]}" = "$reason" ]; then
                        unset 'touch_reasons[i]'
                        break
                    fi
                done
            fi

            if [ "''${#touch_reasons[@]}" -eq 0 ]; then
                printf '{"text": ""}\n'
            else
                printf '{"text": "", "tooltip": "%s"}\n' "''${touch_reasons[@]}"
            fi
        done

        sleep 1
    done
  '';
in
{
  home.packages = [ waybar-mullvad ];
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = {
      bar = {
        layer = "top";
        position = "top";
        height = if config.variables.isLaptop then 25 else 32;
        #spacing = if config.variables.isLaptop then 6 else 12;
        spacing = 0;

        modules-left = [ "wlr/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "hyprland/submap" "custom/yubikey" "custom/mullvad" ] ++
                        (if config.variables.isLaptop then [ "battery"] else []) ++
                        [ "disk" "memory" "cpu" "network" "tray" ];

        "wlr/workspaces" = {
          sort-by-name = false;
          sort-by-number = true;
          format = "{name}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
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

        "custom/yubikey" = {
          exec = "${waybar-yubikey}/bin/waybar-yubikey";
          return-type = "json";
        };

        "custom/mullvad" = {
          exec = "${waybar-mullvad}/bin/waybar-mullvad status";
          on-click = "${waybar-mullvad}/bin/waybar-mullvad toggle &";
          on-click-right = "${waybar-mullvad}/bin/waybar-mullvad menu &";
          on-click-middle = "${waybar-mullvad}/bin/waybar-mullvad ip-clip &";
          return-type = "json";
        };

        "disk" = {
          interval = 30;
          states = {
            okay = 0;
            high = 60;
            warning = 80;
            critical = 90;
          };
          format = "";
          path = "/";
        };

        "memory" = {
          interval = 2;
          states = {
            okay = 0;
            high = 60;
            warning = 80;
            critical = 90;
          };
          format = "";
        };

        "cpu" = {
          inverval = 2;
          states = {
            okay = 0;
            high = 60;
            warning = 80;
            critical = 90;
          };
          format = "";
        };

        "network" = {
          format = "";
          format-ethernet = " ";
          format-wifi = "";
          format-disconnected = "";
          format-disabled = "";
          tooltip = true;
          tooltip-format = "{ipaddr} on {ifname} via {gwaddr}";
          tooltip-format-ethernet = "{ipaddr} on {ifname} via {gwaddr}";
          tooltip-format-wifi = "{ipaddr} on {ifname} via {gwaddr} on {essid} ({signalStrength}%)";
          tooltip-format-disconnected = "Disconnected";
          tooltip-format-disabled = "Disabled";
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
        font-family: monospace;
        font-size: ${if config.variables.isLaptop then "16" else "20"}px;
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

      #workspaces,
      #window,
      #clock,
      #submap,
      #custom-yubikey,
      #custom-mullvad,
      #battery,
      #disk,
      #memory,
      #cpu {
        padding: 0 0;
        margin: 0 2px;
      }
      #network {
        padding: 0 0;
        margin: 0 10px 0 2px;
      }
      #tray {
        margin-right: 10px;
      }


      #custom-yubikey,
      #custom-mullvad,
      #disk,
      #memory,
      #cpu,
      #network {
        color: #${colors.base00};
        font-size: 30px;
        min-width: 32px;
      }

      .connected,
      .okay,
      .linked,
      .ethernet {
        background-color: #${colors.base0B};
      }
      .high,
      .connecting {
        background-color: #${colors.base0A};
      }
      .warning {
        background-color: #${colors.base09};
      }
      .critical,
      .disconnected {
        background-color: #${colors.base08};
      }

      #custom-yubikey {
        background-color: #${colors.base0A};
      }

      #network.disabled {
        background-color: #${colors.base0A};
      }
      #network.disconnected {
        background-color: #${colors.base08};
      }
      #network.wifi {
        background-color: #${colors.base0C};
      }
    ''; # TODO: custom modules sizing for laptop
  };
}
