{ config, pkgs, ... }: {
  imports = [ 
    ./rofi.nix
    ./hyprland.nix
    ./waybar.nix
    ./screen-locker.nix
  ];

  home.packages = with pkgs; [ hyprpaper hyprpicker wl-clipboard udiskie qt6.qtwayland libsForQt5.qt5.qtwayland libsForQt5.qt5ct libva ];

  home.file.".config/hypr/hyprpaper.conf".text = ''preload = ${config.wallpaper}
  wallpaper = ,${config.wallpaper}'';

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
