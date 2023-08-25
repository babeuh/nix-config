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
  age.yubikey.identities = [
    "AGE-PLUGIN-YUBIKEY-16RW96QVZ93EDGKC0XP44A"
    "AGE-PLUGIN-YUBIKEY-1CRW46QVZENMMENGVMDRGN"
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
}
