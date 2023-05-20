{ inputs, pkgs, config, ... }:
let
  inherit (config.colorscheme) colors;
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
    nvidiaPatches = true;
    recommendedEnvironment = true;

    extraConfig = ''
      monitor=DP-1, 2560x1440@144, 0x0, 1

      env=__GLX_VENDOR_LIBRARY_NAME,nvidia
      env=_JAVA_AWT_WM_NONREPARENTING,1
      env=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      env=QT_QPA_PLATFORMTHEME,qt5ct
      env=QT_QPA_PLATFORM,wayland
      env=LIBVA_DRIVER_NAME,nvidia
      env=XDG_SESSION_TYPE,wayland
      env=GDK_BACKEND,wayland
      env=GBM_BACKEND,nvidia-drm
      env=WLR_NO_HARDWARE_CURSORS,1
      env=WLR_BACKEND,vulkan
      env=WLR_RENDERER,vulkan
      env=SDL_VIDEODRIVER,wayland

      input {
        kb_layout=us
        repeat_delay=500
        repeat_rate=20
      }

      general {
        border_size=2
        col.inactive_border=rgb(${colors.base03})
        col.active_border=rgb(${colors.base05})

        gaps_in=6
        gaps_out=12

        layout=dwindle

        cursor_inactive_timeout=10
        no_cursor_warps=true
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

      bind=SUPER_SHIFT, S, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Pictures/screenshots/$(date +'%s_grim.png')
      bind=SUPER_SHIFT, P, exec, hyprpicker -a
      bind=SUPER, SPACE, exec, pkill rofi || rofi -display-drun "App" -show drun -font "monospace;2" -matching glob

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
      windowrulev2=workspace 5, class:^(discord)$
      windowrulev2=workspace 9, class:^(steamwebhelper)$
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

      exec-once=udiskie &
      exec-once=waybar
      exec-once=hyprpaper

      exec-once=discord
      exec-once=spotifywm
      exec-once=firefox
      exec-once=yubikey-touch-detector -libnotify
    '';
  };
}
