{
  fileSystems."/" = {
    device = "/dev/lvm/NIXOS-ROOT";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/lvm/NIXOS-ROOT";
    fsType = "btrfs";
    options = [ "subvol=persist" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/lvm/NIXOS-ROOT";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/lvm/NIXOS-ROOT";
    fsType = "btrfs";
    options = [ "subvol=log" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "/dev/lvm/NIXOS-ROOT";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/lvm/NIXOS-SWAP"; }];
}
