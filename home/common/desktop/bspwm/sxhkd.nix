{
  services.sxhkd = {
    enable = true;
    keybindings = {
      #
      # wm indepentdent hotkeys
      #

      # terminal
      "super + Return"                  = "alacritty";
      # launcher
      "super + space"                   = "rofi -display-drun \"App\" -show drun -font \"monospace;2\" -matching glob";
      # reload sxhkd
      "super + Escape"                  = "pkill -USR1 -x sxhkd";
      # media keys
      "XF86AudioPlay"                   = "playerctl --ignore-player=firefox play-pause";
      "XF86AudioNext"                   = "playerctl --ignore-player=firefox next";
      "XF86AudioPrev"                   = "playerctl --ignore-player=firefox previous";
      "XF86AudioMute"                   = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioLowerVolume"            = "playerctl volume 0.10-";
      "XF86AudioRaiseVolume"            = "playerctl volume 0.10+";
      # screenshot
      "super + shift + s"               = "scrot -s ~/Pictures/screenshots/scrot_%Y-%m-%d-%H%M%S.png";

      #
      # bspwm hotkeys
      #

      # quit/restart bspwm
      "super + alt + {q,r}"             = "bspc {quit, wm -r}";
      # close and kill
      "super + {_,shift + }w"           = "bspc node -{c,k}";
      # alternate between tiled and monocle layout
      "super + m"                       = "bspc desktop -l next";
      # send the newset marked node to newest preselected node
      "super + y"                       = "bspc node newest.marked.local -n newest.!automatic.local";
      # swap current node and the biggest window
      "super + g"                       = "bspc node -s biggest.window";
      
      #
      # state/flags
      #

      # set the window state
      "super + {t,shift + t,s,f}"       = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen";
      # set the node flags
      "super + ctrl + {m,x,y,z}"        = "bspc node -g {marked,locked,sticky,private}";

      #
      # focus/swap
      #

      # focus the node in the given direction
      "super + {_,shift +}{h,j,k,l}"    = "bspc node -{f,s} {west,south,north,east}";
      # focus the node for the given path jump
      "super + {p,b,comma,period}"      = "bspc node -f @{parent,brother,first,second}";
      # focus the next/previous window in the current desktop
      "super + {_,shift +}c"            = "bspc node -f {next,prev}.local.!hidden.window";
      # focus the next/previous desktop in the current monitor
      "super + bracket{left,right}"     = "bspc desktop -f {prev,next}.local";
      # focus the last node/desktop
      "super + {grave,Tab}"             = "bspc {node,desktop} -f last";
      # focus the older or newer node in the focus history
      "super + {o,i}"                   = ''bspc wm -h off; \
                                          bspc node {older,newer} -f; \
                                          bspc wm -h on'';
      # focus or send to the given desktop
      "super + {_,shift +}{1-9,0}"      = "bspc {desktop -f, node -d} '^{1-9,10}'";

      #
      # preselect
      #

      # preselect the direction
      "super + ctrl + {h,j,k,l}"        = "bspc node -p {west,south,north,east}";
      # preselect the ratio
      "super + ctrl + {1-9}"            = "bspc node -o 0.{1-9}";
      # cancel the preselection for the focused node
      "super + ctrl + space"            = "bspc node -p cancel";
      # cancel the preselection for the focused desktop
      "super + ctrl + shift + space"    = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

      #
      # move/resize
      #

      # expand a window by moving one of its sides outward
      "super + alt + {h,j,k,l}"         = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
      # contract a window by moving one of its sides inward
      "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
      # move a floating window
      "super + alt + ctrl + {h,j,k,l}"  = "bspc node -v {-20 0,0 20,0 -20,20 0}";
    };
  };
}
