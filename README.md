# Future NixOS Config

## Warning!
- This is an early concept
- Yubikey 5(C) required

## Setup
- Boot from minimal iso
- Partition the drive.
  - TODO: make a script to select disk and partition
  ```
  # This script assumes $DISK is set to your prefered disk
  DISK=/dev/nvme0n1

  # Set up partition. I use a 512MB fat32 partition (EFI) and a main LUKS encrypted partition
  parted $DISK

  # LUKS
  cryptsetup --verify-passphrase -v luksFormat /dev/"$DISK"p2
  cryptsetup open /dev/"$DISK"p2 enc

  # Initialize volumegroup `lvm`
  pvcreate /dev/mapper/enc
  vgcreate lvm /dev/mapper/enc
  lvcreate -n NIXOS-SWAP --size 32G pool
  lvcreate -n NIXOS-ROOT --extents 100%FREE pool
  mkswap /dev/lvm/NIXOS-SWAP
  mkfs.btrfs /dev/lvm/NIXOS-ROOT
  
  # Use the swap
  swapon /dev/lvm/NIXOS-SWAP

  # Mount btrfs root partition to initialize subvolumes
  mount -t btrfs /dev/lvm/NIXOS-ROOT /mnt

  # Create subvolumes under btrfs root partition
  btrfs subvolume create /mnt/root
  btrfs subvolume create /mnt/home
  btrfs subvolume create /mnt/nix
  btrfs subvolume create /mnt/persist
  btrfs subvolume create /mnt/log

  # Take an empty readonly snapshot of the btrfs root
  btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
  umount /mnt

  # Mount the subvolumes
  mount -o subvol=root,compress=zstd,noatime    /dev/lvm/NIXOS-ROOT /mnt/
  mkdir /mnt/{boot,home,nix,persist,var/log}
  mount -o subvol=home,compress=zstd,noatime    /dev/lvm/NIXOS-ROOT /mnt/home
  mount -o subvol=nix,compress=zstd,noatime     /dev/lvm/NIXOS-ROOT /mnt/nix
  mount -o subvol=persist,compress=zstd,noatime /dev/lvm/NIXOS-ROOT /mnt/persist
  mount -o subvol=log,compress=zstd,noatime     /dev/lvm/NIXOS-ROOT /mnt/var/log
  mount /dev/"$DISK"p1 /mnt/boot
  ```
- Generate the config
  - TODO: make a script to select host and other config options
  - TODO: change this to refer to my repo
  ```
  nixos-generate-config --root /mnt
  # By default the generated configuration.nix is practically empty so we can overwrite it - feel free to review it first or move it
  curl -sSL https://raw.githubusercontent.com/kjhoerr/dotfiles/trunk/.config/nixos/systems/bootstrap.nix -o /mnt/etc/nixos/configuration.nix
  # The hostname should be changed to "pick" the correct flake
    ```
- Edit hardware-configuration.nix
  - Add ```"compress=zstd" "noatime"``` on each of the btrfs subvolumes
  - Add ```neededForBoot = true``` for persist and log subvolumes
  - Set root LVM
  ```
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/..."; # UUID can be found using: `blkid | grep /dev/nvme0n1p2`
  }
  ```
- ```nixos-install``` and ```reboot```

## TODO
- Yubikey instructions
- More install instructions (documentation)
- Bootstrap script
- Archive sources

## Related / Sources
### Opt-in state
- [kjhoerr's dotfiles](https://github.com/kjhoerr/dotfiles)
- [guekka's blog](https://guekka.github.io/nixos-server-1/)
- [mt-caret's blog](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
- [hadilq's gist](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5)
### Systemd initrd
- [kjhoerr's dotfiles](https://github.com/kjhoerr/dotfiles)
### LUKS and TPM2
- [kjhoerr's dotfiles](https://github.com/kjhoerr/dotfiles)
