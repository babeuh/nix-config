{ pkgs, config, username, ... }: {
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

  environment.persistence."/persist" = {
    directories = [
      { directory = "${config.variables.user.home}/.config/Yubico"; user = username; }
    ];
  };
}
