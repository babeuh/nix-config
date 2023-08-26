# NixOS Config

## Warning!
- This is a personal config, I do not promise that this works for you.
- At least one Yubikey 5 "required"

## Setup
- Boot from minimal iso
- Partition the drive.
  ```
  # This snippet assumes $DISK is set to your prefered disk
  # Example: DISK=/dev/nvme0n1

  # Set up partition. I use a 512MB fat32 partition (EFI) and a main LUKS encrypted partition
  parted $DISK

  # LUKS
  cryptsetup --verify-passphrase -v luksFormat "$DISK"p2
  cryptsetup open "$DISK"p2 enc

  # Initialize volumegroup `lvm`
  pvcreate /dev/mapper/enc
  vgcreate lvm /dev/mapper/enc
  lvcreate -n NIXOS-SWAP --size 32G lvm
  lvcreate -n NIXOS-ROOT --extents 100%FREE lvm
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
  mkdir -p /mnt/{boot,home,nix,persist,var/log}
  mount -o subvol=home,compress=zstd,noatime    /dev/lvm/NIXOS-ROOT /mnt/home
  mount -o subvol=nix,compress=zstd,noatime     /dev/lvm/NIXOS-ROOT /mnt/nix
  mount -o subvol=persist,compress=zstd,noatime /dev/lvm/NIXOS-ROOT /mnt/persist
  mount -o subvol=log,compress=zstd,noatime     /dev/lvm/NIXOS-ROOT /mnt/var/log
  mount "$DISK"p1 /mnt/boot
  ```
- Enable Nix features
  ```
  export NIX_CONFIG="experimental-features = nix-command flakes"
  ```
- Generate the config
  ```
  # This assumes you are in /mnt/persist and that $HOST is your desired hostname
  git clone https://github.com/babeuh/nix-config
  cd nix-config

  # Assuming you want `atlas` config (you can make one yourself or modify atlas)
  cp -r hosts/atlas hosts/$HOST
  nixos-generate-config --root /mnt
  cp -f /mnt/etc/nixos/hardware-configuration.nix ./hosts/$HOST/
  ```
- Edit hardware-configuration.nix in your host's folder
  - Add ```"compress=zstd" "noatime"``` on each of the btrfs subvolumes
  - Add ```neededForBoot = true``` for persist and log subvolumes
  - Set root LVM
  ```
  # UUID can be found using: `blkid | grep "$DISk"p2`
  boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/...";
  ```
- Edit default.nix in your host's folder
  - If you do not use syncthing and copied a config with it remove that section
  - Change the variables
  - Temporarily disable lanzaboote with `boot.loader.systemd-boot.enable = lib.mkOverride 0 true`
- Yubikey Configuration
  - Setup environment with `nix develop`
  - Setup Yubikeys for SSH, for each of your Yubikeys:
    1. Run `yubikey-agent -setup`
    2. Add the given ssh public key anywhere (ex: in GitHub for authentication and signing)
  - Setup Yubikeys for PAM
    - With `$USER` being your username 
    1. Run `mkdir -p /mnt/persist/home/$USER/Yubico/.config/Yubico`
    2. Run `pamu2fcfg > /mnt/persist/$USER/Yubico/.config/Yubico/u2f_keys`
       - To add another Yubikey run `pamu2fcfg -n >> /mnt/persist/home/$USER/Yubico/.config/Yubico/u2f_keys`
  - Setup Agenix
    - WARNING: Assume that your encryption will be broken by quantum computers, don't put your secrets in a public git repo unless it is impossible to use it to break your security. This config needs a Yubikey for PAM so making the encrypted user password public should be fine afaik.
    - For each of your Yubikeys:
      1. Run `age-plugin-yubikey`
      2. Add the given age public key to `secrets/secrets.nix`
    - Run `agenix -e $USER-password.age` with `$USER` being your username and type your desired password
- Run `nixos-install --flake .#$HOST` with `$HOST` being your desired host and `reboot`
- Setup TPM LUKS disk encryption with PIN (can be any characters and any length)
  ```
  # This snippet assumes $DISK is set to your prefered disk and you are using root
  systemd-cryptenroll --wipe-slot=tpm2 "$DISK"p2 --tpm2-with-pin=yes --tpm2-device=auto --tpm2-pcrs=0+2+7
  # Optionally if you only want to rely on tpm: systemd-cryptenroll --wipe-slot=password
  ```
- Setup Secure Boot
  - Make sure Secure Boot is enabled and in Setup Mode
  - Make sure to read this [Lanzaboote Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
  - Steps 2, 4, 5 and 6 require the environment provided by `nix develop`
  1. Edit your host's config and remove `boot.loader.systemd-boot.enable = lib.mkOverride 0 true`
  2. Create secure boot keys by running `sbctl create-keys` with root permissions
  3. Rebuild your system by running `nixos-rebuild switch --flake .` with root permissions in `/persist/nix-config`
  4. Make sure your .efi files are signed by running `sbctl verify`. Files ending in `-bzImage.efi` are not supposed to be signed.
      - If they aren't, delete the unsigned files and go back to step 3.
  5. Run `sbctl enroll-keys --microsoft` with root permissions.
      - Microsoft keys are here for compatability. Do not remove them unless you know what you are doing
  6. Reboot system and make sure Secure Boot is enabled by running `bootctl status` and `sbctl status`
      - If the system does not boot after following these steps go to [Lanzaboote Troubleshooting](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#disabling-secure-boot-and-lanzaboote)

## TODO
- Scripted install

## Related / Sources
- [kjhoerr's dotfiles](https://github.com/kjhoerr/dotfiles)
- [guekka's blog](https://guekka.github.io/nixos-server-1/)<sup>[[archived](http://web.archive.org/web/20230526133048/https://guekka.github.io/nixos-server-1/)]</sup>
- [mt-caret's blog](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)<sup>[[archived](http://web.archive.org/web/20230526133332/https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)]</sup>
- [hadilq's gist](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5)<sup>[[archived](http://web.archive.org/web/20230526133617/https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5)]</sup>
- [YubiKey](https://nixos.wiki/wiki/Yubikey)<sup>[[archived](http://web.archive.org/web/20230526133734/https://nixos.wiki/wiki/Yubikey)]</sup>
- [Lanzaboote's Quickstart Guide](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
