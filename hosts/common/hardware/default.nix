{
  imports = [
    ./sound.nix
    ./printing.nix
    ./yubikey.nix
  ];
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
}
