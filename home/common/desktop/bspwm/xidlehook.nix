{ pkgs, config, ... }: {
  services.xidlehook = {
    enable = true;
    not-when-fullscreen = true;
    not-when-audio = true;
    # NOTE: The delays add onto the previous value (and the value is in seconds)
    timers = [
      {
        delay = 240;
        command = ''
          ${pkgs.dunst}/bin/dunstify -a betterlockscreen -u critical "Locking screen in 1 min"'';
        canceller = ''
          ${pkgs.dunst}/bin/dunstify -a betterlockscreen -u low "Locking screen cancelled"'';
      }
      {
        delay = 60;
        command =
          "${pkgs.betterlockscreen}/bin/betterlockscreen -u ${config.wallpaper} --fx \"\" && ${pkgs.betterlockscreen}/bin/betterlockscreen -l";
      }
    ];
  };
}
