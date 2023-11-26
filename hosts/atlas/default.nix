{ config, ... }: {
  imports = [
    ../common/gaming
    ../common/virtualisation
    ../common/flatpak
    ../common/openrgb
    ../common/syncthing.nix

    ../common/hardware/nvidia.nix
    ../common/hardware/sweep.nix
    ../common/hardware/numworks.nix
    ../common/hardware/drawing.nix
    ../common/filesystem.nix
    ./hardware-configuration.nix
  ];
  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.settings.devices = {
    "iapetus".id = "BD53N23-HAKXFK3-UBWGRBQ-FRRBBLZ-66PTMGJ-HKFBOEL-KUJ4LNY-KTTNGQX";
    "phone".id   = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
  };
  services.syncthing.settings.folders = {
    "KeePassXC" = {
      id = "4wmxy-pdg0y";
      label = "KeePassXC";
      path = "${config.variables.user.home}/KeePassXC";
      devices = [ "iapetus" "phone" ];
    };
    "Obsidian Vault" = {
      id = "wlwgj-bhqfx";
      label = "Obsidian Vault";
      path = "${config.variables.user.home}/Obsidian Vault";
      devices = [ "iapetus" "phone" ];
    };
  };

  # Sound config
  environment.etc."wireplumber/main.lua.d/51-host-config.lua".source = ./51-host-config.lua;
  variables.sound = {
    quantum = 256;
    rate = 92000;
    allowed-rates = [ 44100 48000 88200 96000 ];
  };
}
