{ config, lib, pkgs, ... }:
let
  pcscdCfg = pkgs.writeText "reader.conf" "";
  pcscdPkg = pkgs.pcsclite;
  pcscdPluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") [ pkgs.ccid ];
  };
in {
  age.secrets = {
    babeuh-password.file = ../../secrets/babeuh-password.age;
  };

  age.yubikeySupport = true;
  age.yubikeyIdentityPaths = [
    ../../secrets/identities/babeuh.txt
    ../../secrets/identities/babeuh-backup.txt
  ];

  age.secretsDir = "/persist/agenix/secrets";
  age.secretsMountPoint = "/persist/agenix/generations";

  # HACK: Start pcscd before decrypting secrets
  services.pcscd.enable = lib.mkForce true;
  boot.initrd.systemd = {
    packages = [ (lib.getBin pcscdPkg)];
    # probably not necessary
    extraBin = {
      pcscd = "${pcscdPkg}/bin/pcscd";
    };
    storePaths = [
      "${pkgs.ccid}" # maybe not necessary
      "${pcscdPkg}/bin/pcscd"
      "${pcscdCfg}"
      "${pcscdPluginEnv}"
    ];

    sockets.pcscd.wantedBy = [ "sockets.target" ];
    services.pcscd = {
      environment.PCSCLITE_HP_DROPDIR = pcscdPluginEnv;
      after = [
        "rollback.service"
      ];
      serviceConfig.ExecStart = [
        ""
        "${pcscdPkg}/bin/pcscd -f -c ${pcscdCfg}"
      ];
    };
  };

}
