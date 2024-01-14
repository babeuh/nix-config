{ config, lib, pkgs, username, ... }:
let
  pcscdCfg = pkgs.writeText "reader.conf" "";
  pcscdPkg = pkgs.pcsclite;
  pcscdPluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") [ pkgs.ccid ];
  };
in {
  imports = [
    ./users/${username}.nix
  ];
  age.secretsDir = "/persist/agenix/secrets";
  age.secretsMountPoint = "/persist/agenix/generations";
  age.secrets = {
    "${username}-password".file = ../../secrets/${username}-password.age;
  };

  # Enable custom yubikey support
  age.yubikey.enable = true;

  services.pcscd.enable = lib.mkForce true;
  systemd.services.pcscd.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pcscdPkg}/bin/pcscd -f -c ${pcscdCfg}"
  ];

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
