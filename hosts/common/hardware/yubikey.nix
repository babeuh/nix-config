{
  pkgs,
  config,
  username,
  ...
}:
{
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
      control = "sufficient";
      cue = true;
    };
  };
  environment.persistence."/persist".users.${username}.directories = [ "Yubico/.config/Yubico" ];
}
