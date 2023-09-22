{ config, username, ... }: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.age.secrets."${username}-password".path;
  };
}
