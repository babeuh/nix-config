{ lib, config, pkgs, ... }: {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "btrfs" ];
    # FIXME: Might have to move to latest instead of zen
    kernelPackages = pkgs.linuxPackages_zen;
    # TODO: Set root.device in each system configuration
    initrd.luks.devices.root.preLVM = true;
    # Fixes Hogwarts Legacy on steam (or used to)
    kernel.sysctl."vm.max_map_count" = 1000000;
    # lanzboote uses systemd-boot consoleMode
    loader.systemd-boot.consoleMode = "max";

    # TODO: Enable this when stable
    # Quiet boot with plymouth - supports LUKS passphrase
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth.enable = true;

    # Bootspec and Secure Boot using lanzaboote
    #
    # This throws a bootspec RFC warning - proceed with caution. May need to clear existing /boot entries first:
    # sudo rm -rf /boot/*aaaa
    #
    # Commands for reference:
    # sudo sbctl create-keys             # Should be persisted, default is in /etc/secureboot. will not overwrite existing keys
    # sudo sbctl verify                  # Will show warning for any files that will cause lockup while Secure Boot is enabled
    # sudo bootctl status                # View current boot status
    # sudo sbctl enroll-keys --microsoft # Add your SB keys to UEFI - must be in Secure Boot setup mode to enroll keys
    #
    # Most importantly, review this document:
    # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
    #
    bootspec.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
  
  # TODO: Check dock to make this 2fa and add to README.md
  # related: https://github.com/systemd/systemd/pull/22563
  # related: https://gist.github.com/chrisx8/cda23e2d1fa3dcda0d739bc74f600175 ( THIS IS OLD )
  # related: https://www.reddit.com/r/NixOS/comments/xrgszw/nixos_full_disk_encryption_with_tpm_and_secure/
  # TODO: Also make FIDO2 as 2fa
  # related: https://github.com/systemd/systemd/issues/21427

  # TPM for unlocking LUKS
  #
  # TPM kernel module must be enabled for initrd. Device driver is viewable via the command:
  # sudo systemd-cryptenroll --tpm2-device=list
  # And added to a device's configuration:
  # boot.initrd.kernelModules = [ "tpm_tis" ];
  #
  # Must be enabled by hand - e.g.
  # sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p3 --tpm2-device=auto --tpm2-pcrs=0+2+7
  #
  boot.initrd.kernelModules = [ "tpm_tis" ];
  security.tpm2.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
}
