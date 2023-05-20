{ pkgs, lib, ... }: {
  age.secrets = {
    babeuh-password.file = ./babeuh-password.age;
  };

  # TODO: Replace path with something else, probably just a ./identities/... and not a string
  age.identityPaths = [
    "/persist/future-nix-config/secrets/identities/babeuh.txt"
    "/persist/future-nix-config/secrets/identities/babeuh-backup.txt"
  ];

  age.secretsDir = "/persist/agenix/secrets";
  age.secretsMountPoint = "/persist/agenix/generations";

  # HACK: pcscd is not available yet, maybe start it custom
  # TODO: use systemd initrd for this
  #system.activationScripts.agenixNewGeneration.deps = [ "specialfs" ""]

  # HACK: systemPackages don't exist in activation yet so our plugin is undetected
  age.ageBin = "${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey --list;PATH=$PATH:${lib.makeBinPath [ pkgs.age-plugin-yubikey ]} ${pkgs.rage}/bin/rage";
}
