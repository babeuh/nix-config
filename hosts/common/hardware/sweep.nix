{ inputs, ... }: {
  # This is to flash my Sweep's liatris controllers (RP2040)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", MODE="0666"
  '';
}
