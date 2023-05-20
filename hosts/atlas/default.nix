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
}
