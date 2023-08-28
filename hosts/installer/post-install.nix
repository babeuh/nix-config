{ pkgs, username, hostname, ... }:
let
  post-install-setup = pkgs.writeShellScriptBin "post-install-setup" ''
    set -euo pipefail
    
    # Change permissions of stuff in /persist
    ${pkgs.sudo}/bin/sudo chown -R ${username} /persist/nix-config
    ${pkgs.sudo}/bin/sudo chown -R ${username} /persist/home/${username}
    ${pkgs.sudo}/bin/sudo chmod 750 /persist/home
    chmod -R 755 /persist/home/${username}
    chmod 750 /persist/home/${username}
    
    ${secure-boot-setup}/bin/secure-boot-setup
  '';

  secure-boot-setup = pkgs.writeShellScriptBin "secure-boot-setup" ''
    set -euo pipefail
    cd /persist/nix-config

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

    askYesNo "Have you enabled and put Secure Boot in Setup Mode" true || {
      echo "Reboot, go to your BIOS settings, and do that"
      echo "Then run \"secure-boot-setup\""
      exit 0
    }
    # Enable lanzaboote
    ${pkgs.gnused}/bin/sed -i "/boot.loader.systemd-boot.enable = lib.mkOverride 0 true;/d" hosts/${hostname}/default.nix
    ${pkgs.sudo}/bin/sudo ${pkgs.sbctl}/bin/sbctl create-keys
    sudo nixos-rebuild switch --flake .
    ${pkgs.sudo}/bin/sudo ${pkgs.sbctl}/bin/sbctl verify
    askYesNo "Are the files that do not end in -bzImage.efi signed" true || {
      echo "Delete the unsigned files and follow the Secure Boot instructions in the README"
      echo "You can pick back up at step 3"
      exit 0
    }
    ${pkgs.sudo}/bin/sudo ${pkgs.sbctl}/bin/sbctl enroll-keys --microsoft
    ${pkgs.gnused}/bin/sed -i "/installer\/post-install/d" hosts/${hostname}/default.nix

    echo "Done! Reboot the system once you are ready to continue..."
    echo "Once you have rebooted, follow step 6 of the Secure Boot instructions in the README"
  '';
in {
  environment.systemPackages = [
    post-install-setup
    secure-boot-setup
  ];
}
