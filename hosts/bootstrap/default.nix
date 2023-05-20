{ lib, ... }: {
  variables.user.name = "user";
  variables.user.password = "password";
  # TODO: Bootstrap Host (useful for lanzaboote)
  boot.loader.systemd-boot.enable = lib.mkOverride 0 true;

  boot.lanzaboote = {
    enable = lib.mkOverride 0 true;
    pkiBundle = "/etc/secureboot";
  };
}
