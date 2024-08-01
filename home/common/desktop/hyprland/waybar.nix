{
  pkgs,
  outputs,
  config,
  ...
}:
let
  colors = config.colors;
  waybar-mullvad = pkgs.writeShellScriptBin "waybar-mullvad" ''
    #!/usr/bin/env bash
    ## [Set VPN commands]. Setup for Mullvad is done below.
    # The first three commands should have direct equivalents for most VPNs.
    # The relay_set command assumes <country_code> <city_code> will follow as arguments. See below.
    VPN_CONNECT="${pkgs.mullvad-vpn}/bin/mullvad connect"
    VPN_DISCONNECT="${pkgs.mullvad-vpn}/bin/mullvad disconnect"
    VPN_GET_STATUS="${pkgs.mullvad-vpn}/bin/mullvad status"
    VPN_ENTRY_SET_LOCATION="${pkgs.mullvad-vpn}/bin/mullvad relay set tunnel wireguard entry-location"
    VPN_RELAY_SET_LOCATION="${pkgs.mullvad-vpn}/bin/mullvad relay set location"

    ## [Set VPN status parsing]
    # The first command cuts the status, which is compared to keywords below.
    # It's made to be fairly generic to apply across VPNs.
    VPN_STATUS="$($VPN_GET_STATUS | ${pkgs.gnugrep}/bin/grep -Eio 'connected|connecting|disconnect' | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')"
    CONNECTED="connected"
    CONNECTING="connecting"


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
          if [ "$1" == "1" ]; then
            text="$(echo $line | grep -o "..-...-..\?.-[0-9][0-9][0-9]" | head -n 1)"
            tooltip="Connected to $(echo $line | ${pkgs.gnused}/bin/sed -n 's/.*in //p')"
          else
            text=""
            tooltip=""
            class="connected"
          fi
        elif [ "$VPN_STATUS" = "$CONNECTING" ]; then
          if [ "$1" == "1" ]; then
            text="$(echo $line | grep -o "..-...-..\?.-[0-9][0-9][0-9]" | head -n 1)"
            tooltip="Connecting to $(echo $line | ${pkgs.gnused}/bin/sed -n 's/.*in //p')"
          else
            text=""
            tooltip=""
            class="connecting"
          fi
        else
          if [ "$1" == "1" ]; then
            text="Disconnected"
            tooltip="Disconnected"
          else
            text=""
            tooltip=""
            class="disconnected"
          fi
        fi
        printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
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
      ENTRY="$(${pkgs.rofi-wayland}/bin/rofi -location 3 -theme-str "window { height: 250px; width: 250px; x-offset: -312px; y-offset: 10px; }" -sep "\n" -dmenu -i -p "Mullvad VPN Entry" -input "$DIRNAME"/locations)"
      EXIT="$(${pkgs.rofi-wayland}/bin/rofi -location 3 -theme-str "window { height: 250px; width: 250px; x-offset: -312px; y-offset: 10px; }" -sep "\n" -dmenu -i -p "Mullvad VPN Exit" -input "$DIRNAME"/locations)"

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
      status) vpn_report $2 ;;
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
                if [ "$1" == "0" ]; then
                  printf '{"text": ""}\n'
                else
                  printf '{"text":"%s"}\n' "''${touch_reasons[@]}"
                fi
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

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right =
          [
            "hyprland/submap"
            "custom/yubikey#icon"
            "custom/yubikey#data"
            "custom/mullvad#icon"
            "custom/mullvad#data"
          ]
          ++ (if config.variables.isLaptop then [ "battery" ] else [ ])
          ++ [
            "disk#icon"
            "disk#data"
            "memory#icon"
            "memory#data"
            "cpu#icon"
            "cpu#data"
            "mpd#icon"
            "mpd#data"
            "clock#icon"
            "clock#data"
            "tray"
          ];

        "hyprland/workspaces" = {
          sort-by = "number";
          format = "{name}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
        };

        "hyprland/window" = {
          format = "{}";
          seperate-outputs = true;
        };

        "custom/yubikey#icon" = {
          exec = "${waybar-yubikey}/bin/waybar-yubikey 0";
          return-type = "json";
        };

        "custom/yubikey#data" = {
          exec = "${waybar-yubikey}/bin/waybar-yubikey 1";
          return-type = "json";
        };

        "custom/mullvad#icon" = {
          exec = "${waybar-mullvad}/bin/waybar-mullvad status 0";
          on-click = "${waybar-mullvad}/bin/waybar-mullvad toggle &";
          on-click-right = "${waybar-mullvad}/bin/waybar-mullvad menu &";
          on-click-middle = "${waybar-mullvad}/bin/waybar-mullvad ip-clip &";
          return-type = "json";
        };
        "custom/mullvad#data" = {
          exec = "${waybar-mullvad}/bin/waybar-mullvad status 1";
          return-type = "json";
        };

        "disk#icon" = {
          interval = 30;
          states = {
            okay = 0;
            high = 60;
            warning = 80;
            critical = 90;
          };
          format = "";
          tooltip-format = "";
          path = "/";
        };
        "disk#data" = {
          interval = 30;
          format = "{percentage_used}%";
          tooltip-format = "{used}/{total}";
          path = "/";
        };

        "memory#icon" = {
          interval = 2;
          states = {
            okay = 0;
            high = 60;
            warning = 80;
            critical = 90;
          };
          format = "";
          tooltip-format = "";
        };
        "memory#data" = {
          interval = 2;
          format = "{percentage}%";
          tooltip-format = "{used}GiB/{total}GiB";
        };

        "cpu#icon" = {
          inverval = 2;
          states = {
            okay = 0;
            high = 60;
            warning = 80;
            critical = 90;
          };
          format = "";
          tooltip-format = "";
        };
        "cpu#data" = {
          inverval = 2;
          format = "{usage}%";
          tooltip-format = "{avg_frequency}";
        };

        "mpd#icon" = {
          format = "";
          format-stopped = "";
          on-click = "${pkgs.mpc-cli}/bin/mpc toggle";
          on-click-right = "${pkgs.mpc-cli}/bin/mpc shuffle";
          on-click-middle = "${pkgs.mpc-cli}/bin/mpc clear";
          on-scroll-up = "${pkgs.mpc-cli}/bin/mpc prev";
          on-scroll-down = "${pkgs.mpc-cli}/bin/mpc next";
          tooltip = false;
        };
        "mpd#data" = {
          interval = 1;
          format = "{artist} - {album} - {title}";
          format-paused = "{artist} - {album} - {title} (paused)";
          tooltip-format = "{elapsedTime:%M:%S}/{totalTime:%M:%S} - {songPosition}/{queueLength}";
          tooltip-format-disconnected = "disconnected";
          max-length = 50;
        };

        "clock#icon" = {
          format = "";
          tooltip-format = "";
        };
        "clock#data" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          tooltip = true;
          tooltip-format = "{:%A the %Y-%m-%d}";
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
        font-size: ${if config.variables.isLaptop then "14" else "18"}px;
        min-height: 0;
        color: #${colors.foreground};
        text-shadow: rgba(0,0,0,0);
      }

      window#waybar {
        background: #${colors.background};
        color: #${colors.foreground-alt};
      }

      tooltip {
        background: #${colors.background-selection}
      }
      tooltip label {
        color: #${colors.foreground-alt};
      }
      #workspaces {
        margin-left: 10px;
      }
      #workspaces button {
        background: #${colors.foreground};
        padding: 2px 8px 0 8px;
        margin: 4px 0;
        min-width: 32px;
      }
      #workspaces button:hover {
        background: #${colors.foreground-alt};
        text-shadow: none;
        box-shadow: none;
      }
      #workspaces button label {
        color: #${colors.background};
      }
      #workspaces button.active {
        background: #${colors.orange-brown};
      }

      .data {
        color: #${colors.background};
        background: #${colors.foreground};
        padding: 2px 8px 0 8px;
        margin: 4px 2px 4px 0;
        min-width: 32px;
      }
      #custom-mullvad.data {
        min-width: 112px
      }
      .icon {
        color: #${colors.background};
        margin: 4px 0 4px 2px;
        font-size: 20px;
        min-width: 32px;
      }
      #tray {
        margin: 0 10px;
      }


      .connected,
      .okay {
        background: #${colors.green};
      }
      .high,
      .connecting {
        background: #${colors.yellow-bright};
      }
      .warning {
        background: #${colors.yellow};
      }
      .critical,
      .disconnected {
        background: #${colors.red};
      }

      #mpd.icon {
        background: #${colors.purple};
      }
      #clock.icon {
        background: #${colors.blue};
      }
      #custom-yubikey.icon {
        background: #${colors.yellow-bright};
      }
    ''; # TODO: custom modules sizing for laptop
  };
}
