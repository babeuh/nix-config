{
  services.udev.extraRules = ''
    # Gaomon S620
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006d", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006f", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006d", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006f", MODE="0666"
    SUBSYSTEM=="input", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006d", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    SUBSYSTEM=="input", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006f", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';
  hardware.opentabletdriver.enable = true;
}
