{ config, ... }: {
  services = {
    syncthing = {
      dataDir = "${config.variables.user.directory}/Documents";
      configDir = "${config.variables.user.directory}/.config/syncthing";
      guiAddress = "localhost:8384";
      openDefaultPorts = true;
      user = config.variables.user.name;
      group = "users";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
    };
  };
}
