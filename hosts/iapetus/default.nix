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
    "atlas".id = "SZ6GVNW-GPEGDFY-D4FNAVD-LWWWA5L-MLERO3J-AQ3D5PV-QH5IDM3-Z530PAM";
    "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
    "phone-2".id = "4TBQQ3J-JDGERWN-YPYDYSU-H6RXN56-7CEFV2N-6N54WEG-3G2M2XB-FP222AA";
  };
  services.syncthing.folders = {
    "KeePassXC" = {
      id = "4wmxy-pdg0y";
      label = "KeePassXC";
      path = "${config.variables.user.directory}/KeePassXC";
      devices = [ "atlas" "phone" "phone-2" ];
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