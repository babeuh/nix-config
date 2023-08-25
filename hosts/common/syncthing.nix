{ config, username, ... }: {
  services = {
    syncthing = {
      dataDir = "${config.variables.user.home}/Documents";
      configDir = "${config.variables.user.home}/.config/syncthing";
      guiAddress = "localhost:8384";
      openDefaultPorts = true;
      user = username;
      group = "users";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
    };
  };
}
