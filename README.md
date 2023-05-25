# NixOS Config

## Warning!
- This is an early concept
- Yubikey 5(C) required

## Setup
- Boot from minimal iso
- Partition the drive.
  - TODO: make a script to select disk and partition
  ```
  # This snippet assumes $DISK is set to your prefered disk
  # Example: DISK=/dev/nvme0n1

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
- Generate the config (in progress)
  - TODO: make a script to select host and other config options
  - TODO: fix this
  ```
  # This assumes you are in /mnt/persist and that $HOSTNAME is your desired hostname
  git clone https://github.com/babeuh/nix-config
  cd nix-config

  # Assuming you want `atlas` config (you can make one yourself or modify atlas)
  cp -r hosts/atlas hosts/$HOSTNAME
  nixos-generate-config --root /mnt
  cp -f /etc/nixos/hardware-configuration.nix ./hosts/$HOSTNAME/
  ```
- Edit hardware-configuration.nix in your host's folder
  - TODO: make a script that does this
  - Add ```"compress=zstd" "noatime"``` on each of the btrfs subvolumes
  - Add ```neededForBoot = true``` for persist and log subvolumes
  - Set root LVM
  ```
  # UUID can be found using: `blkid | grep /dev/"$DISk"p2`
  boot.initrd.luks.devices.root.device ="/dev/disk/by-uuid/...";
  ```
- Edit default.nix in your host's folder (in progress)
  - If you do not use syncthing and copied a config with it remove that section
  - Change the variables
- Create secrets
  - TODO: finish this
  - yubikey-agent first
  - age-plugin-yubikey second
  - agenix
- ```nixos-install``` and ```reboot```
- If using tpm for decryption
  ```
  # This snippet assumes $DISK is set to your prefered disk and you are using root
  systemd-cryptenroll --wipe-slot=tpm2 /dev/"$DISK"p2 --tpm2-with-pin=yes --tpm2-device=auto --tpm2-pcrs=0+2+7
  # Optionally if you only want to rely on tpm: systemd-cryptenroll --wipe-slot=password
  ```

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
