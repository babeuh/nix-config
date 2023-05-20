{ config, ... }: {
  services = {
    syncthing = {
      enable = true;
      dataDir = "${config.variables.user.directory}/Documents";
      configDir = "${config.variables.user.directory}/.config/syncthing";
      guiAddress = "localhost:8384";
      openDefaultPorts = true;
      user = config.variables.user.name;
      group = "users";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      # TODO: Move to host config
      devices = {
        "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
      }
      # TODO: Move to host config
      folders = {
        "KeePassXC" = {
          id = "4wmxy-pdg0y"; # TODO: Public value?
          label = "KeePassXC";
          path = "${config.variables.user.directory}/KeePassXC";
          devices = [ "phone" ];
        };
        "Obsidian Vault" = {
          id = "wlwgj-bhqfx";
          label = "Obsidian Vault";
          path = "${config.variables.user.directory}/Obsidian Vault";
          devices = [ "phone" ];
        };
      };
    };
  };
}
