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
  # TODO: Move to a common place between system and home
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Add Caches
      substituters = ["https://hyprland.cachix.org" "https://cache.nixos.org/"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
    };
  };
  # TODO: Move overlays to flake.nix
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    inputs.arkenfox.overlays.default
  ];

  # Default Theme
  colorscheme = lib.mkDefault colorSchemes.gruvbox-dark-hard;
  wallpaper = lib.mkDefault ../backgrounds/vettel-years-pixel-gruvboxish.png;
  home.file.".colorscheme".text = config.colorscheme.slug;
}
