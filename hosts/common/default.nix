{ lib, pkgs, hostname, ... }: {

  imports = [
    # Security
    ./hardening.nix
    ./boot.nix
    ./persistence.nix
    ./secrets.nix
    
    # Core
    ./hardware
    ./gui
    ./nix.nix
    ./network.nix
    ./updates.nix
    ./variables.nix
    ./users.nix

    # NTHs
    ./locale.nix
    ./fonts.nix
  ];

  # Enable trash
  services.gvfs.enable = true;

  # Fixes https://nix-community.github.io/home-manager/index.html#_why_do_i_get_an_error_message_about_literal_ca_desrt_dconf_literal_or_literal_dconf_service_literal
  programs.dconf.enable = true;

  programs.command-not-found.enable = false;
    
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    # NOTE: this doesn't replace PATH, it just adds to it
    # HACK: fix https://github.com/NixOS/nix/issues/7512
    PATH = [ "\${XDG_BIN_HOME}:\${PATH}" ];
  };

  # Default packages
  environment.systemPackages = with pkgs; [
    home-manager
    nano # Backup text editor
    git
  ];
  
  # Remove unused packages
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];
}

