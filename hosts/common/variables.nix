{ lib, config, username, ... }:
with lib;

let
  cfg = config.variables;
in
{
  options.variables = {
    user = {
      home = mkOption {
        type = types.str;
        default = "/home/${username}";
        description = "The main user's home directory";
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
      allowed-rates = mkOption {
        type = types.listOf types.int;
        default = [ 48000 ];
        description = "Pipewire clock allowed rates";
      };
      quantum = mkOption {
        type = types.int;
        default = 64;
        description = "Pipewire clock quantum";
      };
      min-quantum = mkOption {
        type = types.int;
        default = 32;
        description = "Pipewire min clock quantum";
      };
      max-quantum = mkOption {
        type = types.int;
        default = 8192;
        description = "Pipewire max clock quantum";
      };
      wireplumberExtraConfig = mkOption {
        type = types.path;
        default = null;
        description = "Host config file";
      };
    };
  };
}
