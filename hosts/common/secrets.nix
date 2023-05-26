{ config, lib, pkgs, ... }:
let
  pcscdCfg = pkgs.writeText "reader.conf" "";
  pcscdPkg = pkgs.pcsclite;
  pcscdPluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") [ pkgs.ccid ];
  };
in {
  age.secretsDir = "/persist/agenix/secrets";
  age.secretsMountPoint = "/persist/agenix/generations";
  age.secrets = {
    "${config.variables.user.name}-password".file = ../../secrets/${config.variables.user.name}-password.age;
  };

  # Enable custom yubikey support
  age.yubikey.enable = true;

  services.pcscd.enable = lib.mkForce true;
  # HACK: Start pcscd before decrypting secrets
  boot.initrd.systemd = {
    packages = [ (lib.getBin pcscdPkg)];
    storePaths = [
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
