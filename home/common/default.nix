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
    ./persistence.nix
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

  # Default Theme
  colorscheme = lib.mkDefault colorSchemes.gruvbox-dark-hard;
  wallpaper = lib.mkDefault ../backgrounds/vettel-years-pixel-gruvboxish.png;
  home.file.".colorscheme".text = config.colorscheme.slug;

  # EQ
  services.easyeffects = {
    enable = lib.mkDefault true;
    preset = lib.mkDefault "Default";
  };

  systemd.user.services.easyeffects-preset = lib.mkIf config.services.easyeffects.enable {
    Unit = {
      Description = "Easyeffects preset setter";
      Requires = [ "dbus.service"  "easyeffects.service" ];
      After = [ "graphical-session-pre.target" "easyeffects.service" ];
      PartOf = [ "graphical-session.target" "pipewire.service" ];
    };

    Install.WantedBy = [ "graphical-session.target" ];

    Service.ExecStart = "${config.services.easyeffects.package}/bin/easyeffects --load-preset ${config.services.easyeffects.preset}";
  };

  # Bluetooth control forwarder
  services.mpris-proxy.enable = true;
}
