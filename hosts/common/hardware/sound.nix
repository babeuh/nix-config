{ config, pkgs, ... }: {

  sound.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

    # TODO: Low latency
  };

  hardware.pulseaudio.support32Bit = true;
}
