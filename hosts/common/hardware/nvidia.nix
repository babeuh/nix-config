{ config, pkgs, lib, ... }: {
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl

        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;

      # This sets nvidia-drm.modeset=1
      modesetting.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    egl-wayland
  ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
}
