{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    numworks-udev-rules
  ];
}
