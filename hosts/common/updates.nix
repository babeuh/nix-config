{
  # Enable automatic updates through this flake
  # TODO: Not sure about this, maybe make it optional?
  system.autoUpgrade = {
    enable = true;
    flake = "github:babeuh/nix-config";
  };

  # Enable fwupd - apparently does not work well with lanzaboote at the moment
  services.fwupd.enable = true;
}
