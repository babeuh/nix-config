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
      quantum = mkOption {
        type = types.int;
        default = 32;
        description = "Pipewire clock quantum";
      };
    };
  };
}
