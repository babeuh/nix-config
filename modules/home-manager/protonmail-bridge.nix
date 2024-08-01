{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.protonmail-bridge;
in
#Still need to integrate more closely with the email management capabilities of home-manager
{
  ##### interface
  options = {
    services.protonmail-bridge = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Bridge.";
      };

      email = mkOption {
        type = types.str;
        description = "Email address";
      };

      logLevel = mkOption {
        type = types.enum [
          "panic"
          "fatal"
          "error"
          "warn"
          "info"
          "debug"
          "debug-client"
          "debug-server"
        ];
        default = "info";
        description = "The log level";
      };

    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    home.packages = [ pkgs.protonmail-bridge ];

    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Protonmail Bridge";
        After = [
          "multi-user.target"
          "network.target"
          "wait-for-secrets.service"
        ];
      };

      Service = {
        Type = "simple";
        Restart = "always";
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge -n --log-level ${cfg.logLevel}";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
