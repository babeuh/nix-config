{ inputs, lib, config, pkgs, ... }: {
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
  variables.hostname = "iapetus";

  # WiFi
  networking.networkmanager.enable = true;

  # Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
		bluez_monitor.properties = {
			["bluez5.enable-sbc-xq"] = true,
			["bluez5.enable-msbc"] = true,
			["bluez5.enable-hw-volume"] = true,
			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
		}
	'';

  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.devices = {
    "atlas".id = "4DUAJNX-H6WNYUF-DE6U5KL-FFFG6MK-XIEMIYK-Y27KC4G-JDSTGD7-75UDTQO";
    "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
  };
  services.syncthing.folders = {
    "KeePassXC" = {
      id = "4wmxy-pdg0y";
      label = "KeePassXC";
      path = "${config.variables.user.directory}/KeePassXC";
      devices = [ "atlas" "phone" ];
    };
    "Obsidian Vault" = {
      id = "wlwgj-bhqfx";
      label = "Obsidian Vault";
      path = "${config.variables.user.directory}/Obsidian Vault";
      devices = [ "atlas" "phone" ];
    };
  };
  system.stateVersion = "23.05";
}
