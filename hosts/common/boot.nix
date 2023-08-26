{ lib, config, pkgs, ... }: {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.luks.devices.root.preLVM = true;
    # Fixes Hogwarts Legacy on steam (or used to)
    kernel.sysctl."vm.max_map_count" = 1000000;
    # lanzboote uses systemd-boot consoleMode
    loader.systemd-boot.consoleMode = "max";

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

    # Secure Boot using lanzaboote
    #
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
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
  
  # TODO: Also use FIDO2 as 2fa
  # related: https://github.com/systemd/systemd/issues/21427

  # TPM for unlocking LUKS
  #
  # TPM kernel module must be enabled for initrd. Device driver is viewable via the command:
  # sudo systemd-cryptenroll --tpm2-device=list
  boot.initrd.availableKernelModules = [ "tpm_tis" "tpm_crb" ];
  boot.initrd.luks.devices.root.crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-with-pin=yes" ];
  security.tpm2.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
}
