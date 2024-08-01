{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openrgb
    i2c-tools
    ddccontrol
  ];

  services.udev.packages = [ pkgs.openrgb ];

  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
  ];
}
