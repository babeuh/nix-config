{ inputs, pkgs, config, nixosConfig, ... }:
let
  colors = config.colors;
  ocr = pkgs.writeShellScriptBin "ocr" ''
    #!/usr/bin/env bash
    set -e

    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0)" /tmp/ocr.png
    ${pkgs.tesseract}/bin/tesseract /tmp/ocr.png /tmp/ocr-output
    wl-copy < /tmp/ocr-output.txt
    ${pkgs.libnotify}/bin/notify-send "OCR" "Copied Text: $(wl-paste -n)"
    rm -f /tmp/ocr-output.txt /tmp/ocr.png
  '';
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [ libnotify ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
    enableNvidiaPatches = nixosConfig.programs.hyprland.enableNvidiaPatches;
    recommendedEnvironment = true;

    extraConfig = ''
      ${if config.variables.isLaptop then "" else "monitor=DP-1, 2560x1440@144, 0x0, 1"}

      env=__GLX_VENDOR_LIBRARY_NAME,nvidia
      env=_JAVA_AWT_WM_NONREPARENTING,1
      env=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      env=QT_QPA_PLATFORMTHEME,qt5ct
      env=QT_QPA_PLATFORM,wayland
      env=LIBVA_DRIVER_NAME,nvidia
      env=XDG_SESSION_TYPE,wayland
      env=GDK_BACKEND,wayland
      ${if config.variables.isLaptop then "" else "env=GBM_BACKEND,nvidia-drm"}
      env=WLR_NO_HARDWARE_CURSORS,1
      env=WLR_BACKEND,vulkan
      env=WLR_RENDERER,vulkan
      env=SDL_VIDEODRIVER,wayland

      input {
        kb_layout=us
        repeat_delay=500
        repeat_rate=20
        touchpad {
          natural_scroll=true
        }
      }

      general {
        border_size=2
        col.inactive_border=rgb(${colors.background-least})
        col.active_border=rgb(${colors.foreground})

        gaps_in=${if config.variables.isLaptop then "3" else "6"}
        gaps_out=${if config.variables.isLaptop then "6" else "12"}

        layout=dwindle

        cursor_inactive_timeout=10
        no_cursor_warps=true
      }

      misc {
        disable_hyprland_logo = true;
      }

      dwindle {
        pseudotile=true
      }

      # Media
      bindle=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+
      bindle=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-
      bindl=, XF86AudioPlay, exec, playerctl --ignore-player=firefox play-pause
      bindl=, XF86AudioNext, exec, playerctl --ignore-player=firefox next
      bindl=, XF86AudioPrev, exec, playerctl --ignore-player=firefox previous
      bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

      # Backlight
      bindle=, XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 1%- -q
      bindle=, XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +1% -q

      bind=SUPER_SHIFT, O, exec, ${ocr}/bin/ocr

      bind=SUPER_SHIFT, S, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Pictures/screenshots/$(date +'%s_grim.png')
      bind=SUPER_SHIFT, P, exec, hyprpicker -a
      bind=SUPER, SPACE, exec, pkill rofi || rofi -display-drun "App" -show drun -matching glob

      bind=SUPER, W, killactive
      bind=SUPER_SHIFT, W, killactive
      bind=SUPER, RETURN, exec, alacritty

      # workspaces
      # binds mod + [shift +] {1..10} to [move to] ws {1..10}
      ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = SUPER, ${ws}, workspace, ${toString (x + 1)}
          bind = SUPER_SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}
      bind=SUPER, bracketleft, workspace, m-1
      bind=SUPER, bracketright, workspace, m+1

      windowrulev2=workspace 1, class:^(firefox)$
      windowrulev2=workspace 2, title:^(Spotify)$
      windowrulev2=workspace 3, class:^(Gimp-?\d?\.?[0-9]+)$
      windowrulev2=workspace 3, class:^(krita)$
      windowrulev2=workspace 4, class:^(Logseq)$
      windowrulev2=workspace 4, class:^(obsidian)$
      windowrulev2=workspace 5, class:^(WebCord)$
      windowrulev2=workspace 9 silent, class:^(steam)$
      windowrulev2=workspace 9, class:^(heroic)$
      windowrulev2=workspace 10, class:^(steam_app_[0-9]+)$

      # Focus
      bind=SUPER, left, movefocus, l
      bind=SUPER, right, movefocus, r
      bind=SUPER, up, movefocus, u
      bind=SUPER, down, movefocus, d

      # Resize submap
      bind=ALT, R, submap, resize
      submap=resize
      binde=, left, resizeactive, -10 0
      binde=, right, resizeactive, 10 0
      binde=, up, resizeactive, 0 -10
      binde=, down, resizeactive, 0 10
      bind=, escape, submap, reset 
      submap=reset

      # Move submap
      bind=ALT, M, submap, move
      submap=move
      binde=, left, moveactive, -10 0
      binde=, right, moveactive, 10 0
      binde=, up, moveactive, 0 -10
      binde=, down, moveactive, 0 10
      bind=, escape, submap, reset 
      submap=reset

      exec-once=mullvad connect
      exec-once=udiskie &
      exec-once=yubikey-touch-detector
      exec-once=waybar
      exec-once=hyprpaper

      exec-once=webcord
      exec-once=spotifywm
      exec-once=firefox
      exec-once=keepassxc
    '';
  };
}
