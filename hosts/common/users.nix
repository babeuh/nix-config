{ config, ... }: {
  users.users.${config.variables.user.name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "libvirtd" ];
    passwordFile = config.variables.user.passwordFile;
    password = config.variables.user.password;
  };
}
