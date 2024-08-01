{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  disko = inputs.disko.packages.x86_64-linux.default;
  disko-config = ./disko.nix;

  setup-system = pkgs.writeShellScriptBin "setup-system" ''
    set -euo pipefail

    # Utility functions
    function askYesNo {
      local default
      local input
      local options
      if [ "$2" = true ]; then
          options="[Y/n]"
          default="y"
      else
          options="[y/N]"
          default="n"
      fi
      read -p "$1 $options " -n 1 -s -r input
      input=''${input:-''${input}}
      echo ''${input}
      if [[ "$input" =~ ^[yY]$ ]]; then
        return 0
      else
        return 1
      fi
    }
    function askUser() {
      local answer
      read -p "$1 " answer
      echo answer
    }
    function waitForUser() {
      read -p "$1 "
    }
    function passwordRequest() {
      local failed=false
      while true; do
        if $failed; then
          echo "Your passwords do not match. Try again" >&2
        fi
        local password=
        local password_verify=

        password=$(${pkgs.systemd}/bin/systemd-ask-password -n "Enter your $1 password:")
        password_verify=$(${pkgs.systemd}/bin/systemd-ask-password -n "Verify your $1 password:")

        if [ "$password" == "$password_verify" ]; then
          echo $password
          break
        else
          failed=true
        fi
      done
    }
    askYesNo "Are you running this script as root" true || {
      echo "Run it as root"
      exit 0
    }
    askYesNo "Have you changed the PIN and PUK of your tokens and enabled the required applications" true || {
      echo "You can use \"ykman\" to do that if you have a Yubikey"
      exit 0
    }

    askYesNo "Use WI-FI" true && {
      systemctl start wpa_supplicant
      wpa_cli
    }

    # LUKS Password
    passwordRequest "LUKS" > /tmp/secret.key


    # Select Disk
    ${pkgs.util-linux}/bin/lsblk -pnd --output NAME > /tmp/disk.list
    ${pkgs.coreutils}/bin/nl /tmp/disk.list
    disk_count="$(${pkgs.coreutils}/bin/wc -l /tmp/disk.list | cut -f 1 -d' ')"
    disk_number=""
    while true; do
      read -p 'Select your disk (ex: 1): ' selected_disk
      # If $disk_number is an integer between one and $disk_count...
      if [ "$disk_number" -eq "$disk_number" ] && [ "$disk_number" -gt 0 ] && [ "$disk_number" -le "$disk_count" ]; then
        break
      fi
    done
    disk="$(${pkgs.gnused}/bin/sed -n "''${n}p" /tmp/disk.list)"
    rm /tmp/disk.list


    echo "Partitioning $disk"
    ${disko}/bin/disko -m create --argstr disk $disk ${disko-config}
    echo "Mounting $disk"
    mkdir /mnt
    ${disko}/bin/disko -m mount --argstr disk $disk ${disko-config}


    echo "Setting system up"
    askYesNo "Use a fork of the config repo" false && {
      git_repo=$(askUser "Enter your fork's https url:")
    }
    ${pkgs.git}/bin/git clone $git_repo /mnt/persist/nix-config
    cd /mnt/persist/nix-config


    username=$(askUser "Enter your desired username:")


    # Token
    multiple_pam=false
    age_token_setup=false
    age_token_new_keys=true
    age_token_new_user=true
    age_token_names=()
    token_backup_rec=" (a backup is recommended)"

    askYesNo "Have you already setup your token(s) for age encryption of any secrets on THIS config/repo" false || {
      rm -r secrets
      mkdir secrets
      ${pkgs.coreutils}/bin/printf "let\n  keys = {\n" > secrets/secrets.nix
    } && {
      age_token_new_keys=false
      askYesNo "Have you set the password for $username in this config?" true && {
        age_token_new_user=false
      }
    }

    if $age_token_new_user; then
      rm -f hosts/common/users/$username.nix
      ${pkgs.coreutils}/bin/printf "{\n  age.yubikey.identities = [\n" > hosts/common/users/$username.nix
    fi

    mkdir -p /mnt/persist/home/$username/Yubico/.config/Yubico
    while true; do
      ssh_token_setup=false
      age_token_setup=false
      echo "1. Plug in a compatible security token"
      echo "2. Make sure only ONE is plugged in"
      echo "3. Make sure no smart card reader or similar is plugged in"
      waitForUser "Press enter to continue"

      echo "Setting up SSH"
      askYesNo "Have you already setup SSH on this token with \"yubikey-agent\"" false || ssh_token_setup=true
      if $ssh_token_setup; then ${pkgs.yubikey-agent}/bin/yubikey-agent -setup; fi

      echo "Setting up age encryption keys"
      if $age_token_new_keys; then
        askYesNo "Have you already setup age encryption keys on this token with \"age-plugin-yubikey\"" false || age_token_setup=true
      fi
      if $age_token_setup; then 
        ${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey -g --slot 1
        age_token_slot=1
      else
        age_token_slot=$(askUser "What slot do use for age on this token (respond with the number only i.e \"1\"):")
      fi

      age_token_key=$(${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey -l --slot $age_token_slot | ${pkgs.coreutils}/bin/tail -n 1)
      age_token_id=$(${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey -i --slot $age_token_slot | ${pkgs.coreutils}/bin/tail -n 1)
      if $age_token_new_keys; then
        age_token_name=$(askUser "What name should this token have in the code (in one word (dashes and underscores allowed)):")
        age_token_names+=($age_token_name)
        ${pkgs.coreutils}/bin/printf "    $age_token_name = \"$age_token_key\";\n" > secrets/secrets.nix
      fi
      if $age_token_new_user; then ${pkgs.coreutils}/bin/printf "    \"$age_token_id\"\n" > hosts/common/users/$username.nix; fi
      echo $age_token_id > /tmp/age_token_id

      echo "Setting up PAM"
      if $multiple_pam; then
        ${pkgs.pam_u2f}/bin/pamu2fcfg -n >> /mnt/persist/$username/Yubico/.config/Yubico/u2f_keys
      else
        ${pkgs.pam_u2f}/bin/pamu2fcfg > /mnt/persist/$username/Yubico/.config/Yubico/u2f_keys
      fi
      if $age_token_new_keys; then askYesNo "Do you have another token to set up$token_backup_rec" false || break; fi
      token_backup_rec=
      multiple_pam=true
    done

    if $age_token_new_keys; then
      ${pkgs.coreutils}/bin/printf "  };\nin\n{\n  \"$username-password\".publicKeys = [" > secrets/secrets.nix
      for name in "''${age_token_names[@]}" ; do
        ${pkgs.coreutils}/bin/printf " keys.$name" > secrets/secrets.nix
      done
      ${pkgs.coreutils}/bin/printf " ];\n}" > secrets/secrets.nix
    fi
    if $age_token_new_user; then
      ${pkgs.coreutils}/bin/printf "  ];\n}" > hosts/common/users/$username.nix
    fi


    # Password Stuff
    echo "Setting up password"
    cd secrets
    echo "Enter the password of $username when ready"
    waitForUser "Press enter to continue"

    ${inputs.agenix.packages.x86_64-linux.default}/bin/agenix -e $username-password.age -i /tmp/age_token_id
    rm /tmp/age_token_id


    # Host Config
    askYesNo "Have you already configured your host" false && {
      host=$(askUser "What is your hostname:")
      ${pkgs.gnused}/bin/sed -i "/hardware-configuration.nix/a\ \ \ \ ../installer/post-install.nix" hosts/$host/default.nix
      echo "When you are ready run \"nixos-install --flake .#$host\" and reboot"
      echo "While rebooting enable Secure Boot and put it in Setup Mode inside your BIOS"
      echo "After the reboot, run \"post-install-setup\""
      exit 0
    };

    host=$(askUser "Enter your desired hostname:")
    ${pkgs.gnused}/bin/sed -i "/nixosConfigurations = {/a\ \ \ \ \ \ \ $host = mkHost \"$host\" \"$username\"" flake.nix
    mkdir hosts/$host

    import_list="\n    ../common/gaming\n    ../common/virtualisation\n    ../common/flatpak\n    ../common/openrgb\n\n    ../common/filesystem.nix\n    ./hardware-configuration.nix\n    ../installer/post-install.nix"

    askYesNo "Do you have an Nvidia GPU" false && import_list="$import_list\n    ../common/hardware/nvidia.nix"

    nixos-generate-config --no-filesystems --root /mnt --dir /persist/nix-config/hosts/$host
    disk_uuid=$(${pkgs.util-linux}/bin/blkid -n crypto_LUKS | ${pkgs.gnugrep}/bin/grep -o "$disk.*: UUID=\".*\" TYPE" | ${pkgs.coreutils}/bin/cut -d'"' -f 2)
    ${pkgs.gnused}/bin/sed -i "/boot.extraModulePackages/a\ \ boot.initrd.luks.devices.root.device = \"/dev/disk/by-uuid/$disk_uuid\";" hosts/$host/hardware-configuration.nix
    ${pkgs.coreutils}/bin/printf "{ lib, ... }: {\n  imports = [$import_list\n  ];\n    boot.loader.systemd-boot.enable = lib.mkOverride 0 true;\n}" > hosts/$host/default.nix

    chmod -R 777 /persist/nix-config
    chmod -R 777 /home/babeuh/Yubico

    echo "For better compatibility with your hardware take a look at https://github.com/NixOS/nixos-hardware"
    echo "You can add them to an \"imports = []\" in \"hosts/$host/hardware-configuration.nix\""
    echo "Take a look at the other configurations' \"hardware-configuration.nix\" to see how they use this"
    echo "When you are ready run \"nixos-install --flake .#$host\" and reboot"
    echo "While rebooting enable Secure Boot and put it in Setup Mode inside your BIOS"
    exit 0
  '';
in
{
  # Remove documentation
  documentation = {
    enable = false;
    nixos.options.warningsAreErrors = false;
    info.enable = false;
  };

  # Enable flakes
  nix.settings = {
    # Add Hyprland Cachix
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

    experimental-features = "nix-command flakes";
  };

  environment.systemPackages = [
    pkgs.git # Required for flakes
    pkgs.neovim # Editor
    pkgs.yubikey-manager # Configure yubikeys

    setup-system
  ];

  # Yubikey support
  services.pcscd.enable = true;
}
