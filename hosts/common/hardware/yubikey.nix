{ pkgs, ... }: {
  services.yubikey-agent.enable = true;

  services.pcscd.enable = true; # TODO: this might need removing (because of boot-time secrets), come back to this

  security.pam = {
    services = {
      swaylock = {
        name = "swaylock";
      };
    };
    u2f = {
      enable = true;
      control = "required";
      cue = true;
    };
  };
}
