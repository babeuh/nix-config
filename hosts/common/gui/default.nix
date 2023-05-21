{ inputs, pkgs, ... }: {

  imports = [
    inputs.hyprland.nixosModules.default

    ./nix.nix
  ];

  xdg.portal.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;

    # Key autorepeat
    autoRepeatDelay = 500;
    autoRepeatInterval = 20;
  };
}
