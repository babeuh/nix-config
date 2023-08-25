{ lib, config, pkgs, hostname, ... }: {
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;

    firewall.enable = true;
    networkmanager.enable = lib.mkDefault false;
    wireguard.enable = true;
  };

  services.mullvad-vpn = {
    package = pkgs.mullvad-vpn;
    enable = true;
  };
}
