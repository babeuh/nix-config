{ inputs, lib, config, ... }: {
  imports = [
    ../common/gaming
    ../common/virtualisation
    ../common/flatpak
    ../common/openrgb

    ../common/hardware/nvidia.nix
    ../common/hardware/sweep.nix
    ../common/hardware/numworks.nix

    ./hardware-configuration.nix
  ];
  age.yubikey.keys = [
    "AGE-PLUGIN-YUBIKEY-16RW96QVZ93EDGKC0XP44A"
    "AGE-PLUGIN-YUBIKEY-1CRW46QVZENMMENGVMDRGN"
  ];

  variables.user.name = "babeuh";
  variables.hostname = "atlas";

  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.devices = {
    "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
  };
  services.syncthing.folders = {
    "KeePassXC" = {
      id = "4wmxy-pdg0y";
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
}
