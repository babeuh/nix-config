{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  quantum-rate = "${toString config.variables.sound.quantum}/${toString config.variables.sound.rate}";
  min-quantum-rate = "${toString config.variables.sound.min-quantum}/${toString config.variables.sound.rate}";
  max-quantum-rate = "${toString config.variables.sound.max-quantum}/${toString config.variables.sound.rate}";

  inherit (lib.generators) toLua;
in
{
  users.users.${username}.extraGroups = [ "audio" ];

  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.support32Bit = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

    extraConfig.pipewire = {
      context = {
        default.clock.quantum = config.variables.sound.quantum;
        default.clock.min-quantum = config.variables.sound.min-quantum;
        default.clock.max-quantum = config.variables.sound.max-quantum;
        default.clock.quantum-limit = config.variables.sound.max-quantum;
        default.clock.rate = config.variables.sound.rate;
        default.clock.allowed-rates = [ config.variables.sound.allowed-rates ];
        modules = [
          {
            name = "libpipewire-module-rtkit";
            args = {
              nice.level = -15;
              rt.prio = 88;
              rt.time.soft = 200000;
              rt.time.hard = 200000;
            };
            flags = [
              "ifexists"
              "nofail"
            ];
          }
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = min-quantum-rate;
              pulse.default.req = quantum-rate;
              pulse.max.req = max-quantum-rate;
              pulse.min.quantum = min-quantum-rate;
              pulse.max.quantum = max-quantum-rate;
              server.address = [ "unix:native" ];
            };
          }
        ];
        stream.properties = {
          node.latency = quantum-rate;
        };
      };
    };

    wireplumber = {
      enable = true;
      configPackages =
        let
          matches =
            toLua
              {
                multiline = false;
                indent = false;
              }
              [
                [
                  [
                    "node.name"
                    "matches"
                    "alsa_output.*"
                  ]
                ]
              ];

          apply_properties = toLua { } {
            "audio.format" = "S32LE";
            "audio.race" = config.variables.sound.rate * 2;
            "api.alsa.period-size" = 2;
          };
        in
        [
          (pkgs.writeTextDir "share/lowlatency.lua.d/99-alsa-lowlatency.lua" ''
            alsa_monitor.rules = {
              matches = ${matches};
              apply_properties = ${apply_properties};
            }
          '')
          config.variables.sound.wireplumberExtraConfig
        ];
    };
  };

  /*
    # Low Latency audio
    home-manager.users.${username}.xdg.configFile = {
      # pulse clients config
      "pipewire/pipewire.conf.d/10-pipewire.conf".text = ''
       context.properties = {
          default.clock.quantum = ${toString config.variables.sound.quantum}
          default.clock.min-quantum = ${toString config.variables.sound.min-quantum}
          default.clock.max-quantum = ${toString config.variables.sound.max-quantum}
          default.clock.quantum-limit = ${toString config.variables.sound.max-quantum}
          default.clock.rate = ${toString config.variables.sound.rate}
          default.clock.allowed-rates = [ ${toString config.variables.sound.allowed-rates} ]
      }'';
    };
  */
}
