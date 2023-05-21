{ config, pkgs, ... }: {
  imports = [ 
    ./rofi.nix
    ./hyprland.nix
    ./waybar.nix
    ./screen-locker.nix
  ];
  nix.settings = {
    # Add Caches
    substituters = ["https://hyprland.cachix.org" "https://cache.nixos.org/"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
  };

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
