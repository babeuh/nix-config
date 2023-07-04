{ outputs, inputs, lib, config, pkgs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./cli
    ./desktop/common
    ./desktop/hyprland
    ./variables.nix
    ./fonts.nix
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
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    inputs.arkenfox.overlays.default
  ];

  # Default Theme
  colorscheme = lib.mkDefault colorSchemes.gruvbox-dark-hard;
  wallpaper = lib.mkDefault ../backgrounds/vettel-years-pixel-gruvboxish.png;
  home.file.".colorscheme".text = config.colorscheme.slug;

  # EQ
  services.easyeffects = {
    enable = true;
    # You need to create a preset with this name
    preset = "Default";
  };
}
