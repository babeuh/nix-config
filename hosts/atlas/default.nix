{ inputs, lib, config, ... }: {
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
  services.syncthing.settings.devices = {
    "iapetus".id = "BD53N23-HAKXFK3-UBWGRBQ-FRRBBLZ-66PTMGJ-HKFBOEL-KUJ4LNY-KTTNGQX";
    "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
  };
  services.syncthing.settings.folders = {
    "KeePassXC" = {
      id = "4wmxy-pdg0y";
      label = "KeePassXC";
      path = "${config.variables.user.directory}/KeePassXC";
      devices = [ "iapetus" "phone" ];
    };
    "Obsidian Vault" = {
      id = "wlwgj-bhqfx";
      label = "Obsidian Vault";
      path = "${config.variables.user.directory}/Obsidian Vault";
      devices = [ "iapetus" "phone" ];
    };
  };
}
