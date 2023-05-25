{ config, ... }: {
  users.users.${config.variables.user.name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    passwordFile = config.age.secrets."${config.variables.user.name}-password".path;
  };
}
