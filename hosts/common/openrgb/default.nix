{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    openrgb
    i2c-tools
    ddccontrol
  ];

  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
  ];
}
