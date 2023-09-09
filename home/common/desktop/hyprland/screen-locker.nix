{ pkgs, config, ... }:
let 
  colors = config.colors;
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
      effect-pixelate = "100";

      bs-hl-color = colors.red-bright;
      caps-lock-bs-hl-color = colors.red;
      caps-lock-key-hl-color = colors.purple-bright;
      font = "monospace";
      inside-color = "00000088";
      inside-clear-color = colors.accent;
      inside-caps-lock-color = "00000088";
      inside-ver-color = colors.green;
      inside-wrong-color = colors.red;
      key-hl-color = colors.blue-bright;
      text-color = colors.foreground;
      ring-color = colors.foreground-most;
      ring-ver-color = colors.green;
      ring-wrong-color = colors.red;
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
