{ lib, ... }:
with lib;

let
  cfg = config.variables;
in
{
  options.variables = {
    user = {
      name = mkOption {
        type = types.str;
        description = "The main user's username";
      };
      directory = mkOption {
        type = types.str;
        default = "/home/${cfg.user.name}";
        description = "The main user's home directory";
      };
      passwordFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Password file for user";
      };
      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Password for user";
      };
    };
    hostname = mkOption {
      type = types.str;
      default = "NixOS";
      description = "The hostname";
    };
    sound = {
      rate = mkOption {
        type = types.int;
        default = 48000;
        description = "Pipewire clock rate";
      };
      quantum = mkOption {
        type = types.int;
        default = 32;
        description = "Pipewire clock quantum";
      };
    };
  };
}
