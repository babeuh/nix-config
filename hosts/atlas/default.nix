{ inputs, lib, config, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../common/gaming
    ../common/virtualisation
    ../common/flatpak
    ../common/openrgb

    ../common/hardware/nvidia.nix
    ../common/hardware/sweep.nix

    ./hardware-configuration.nix
  ];
  boot.initrd.luks.devices.root.device = "/dev/nvme0n1p2";

  age.secrets = {
    babeuh-password.file = ../../secrets/babeuh-password.age;
  };

  age.yubikey = {
    enable = true;
    keys = [
      "AGE-PLUGIN-YUBIKEY-16RW96QVZ93EDGKC0XP44A"
      "AGE-PLUGIN-YUBIKEY-1CRW46QVZENMMENGVMDRGN"
    ];
  };

  variables.user.name = "babeuh";
  variables.user.passwordFile = config.age.secrets.babeuh-password.path;
  variables.hostname = "atlas";

  services.xserver.screenSection = ''
    Option        "metamodes" "2560x1440_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}
  '';

  users.users = {
    babeuh = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "audio" "libvirtd" ];
      passwordFile = config.age.secrets.babeuh-password.path;
    };
  };

  services.syncthing.settings.devices = {
    "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
  };
  services.syncthing.settings.folders = {
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
