{ lib, config, ... }: {
  networking = {
    hostName = config.variables.hostname;
    useDHCP = lib.mkDefault true;

    firewall.enable = true;
    networkmanager.enable = lib.mkDefault false;
    wireguard.enable = true;
  };

  services.mullvad-vpn.enable = true;
}
