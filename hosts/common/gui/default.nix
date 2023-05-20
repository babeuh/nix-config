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
    
    # TODO: Move this to specific system
    screenSection = ''
      Option        "metamodes" "2560x1440_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}
    '';
  };
}
