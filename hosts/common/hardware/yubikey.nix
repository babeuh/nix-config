{ pkgs, ... }: {
  services.yubikey-agent.enable = true;

  services.pcscd.enable = true;

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
