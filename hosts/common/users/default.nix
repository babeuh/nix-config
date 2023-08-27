{ config, username, ... }: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    passwordFile = config.age.secrets."${username}-password".path;
  };
}
