{ pkgs, config, ... }:
let 
  inherit (config.colorscheme) colors;
in {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      datestr = "%Y-%m-%d";
      timestr = "%H:%M:%S";
      grace = "1";
      effect-pixelate = "30";

      bs-hl-color = colors.base08;
      caps-lock-bs-hl-color = colors.base09;
      caps-lock-key-hl-color = colors.base0E;
      font = "CozetteVector";
      inside-color = "00000088";
      inside-clear-color = colors.base0A;
      inside-caps-lock-color = "00000088";
      inside-ver-color = colors.base0B;
      inside-wrong-color = colors.base08;
      key-hl-color = colors.base0C;
      text-color = colors.base05;
      ring-color = colors.base07;
      ring-ver-color = colors.base0B;
      ring-wrong-color = colors.base08;
    };
  };
  services.swayidle = {
    enable = false;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      { timeout = 120; command = "${pkgs.swaylock-effects}/bin/swaylock -C ${config.xdg.configFile."swaylock/config".source}"; }
    ];
  };
}
