{ outputs, inputs, lib, config, pkgs, ... }: {
  imports = [
    ./cli
    ./desktop/common
    ./desktop/hyprland
    ./variables.nix
    ./fonts.nix
    ./persistence.nix
    ./themes/gruvbox-dark-hard.nix # Default theme
    ./themes
  ];
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = lib.mkDefault "23.05";
  };

  nixpkgs.config.allowUnfree = true;

  # Set host-specific configuration
  variables.isLaptop = lib.mkDefault false;

  home.file.".colorscheme".text = config.colorScheme.slug;

  # EQ
  # Bluetooth control forwarder
  services.mpris-proxy.enable = true;
}
