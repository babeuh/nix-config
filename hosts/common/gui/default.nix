{ inputs, pkgs, ... }:
{
  imports = [ ./nix.nix ];

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland = {
      enable = true;
    };
  };

  services.displayManager.sddm.enable = true;
  #services.displayManager.gnome.enable = true;
  hardware.pulseaudio.enable = false;

  services.xserver = {
    enable = true;
    #displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Key autorepeat
    autoRepeatDelay = 500;
    autoRepeatInterval = 20;
  };
}
