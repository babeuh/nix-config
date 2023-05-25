{ config, pkgs, ... }:
let
  quantum-rate = "${toString config.variables.sound.quantum}/${toString config.variables.sound.rate}";
  json = pkgs.formats.json {};
in
{
  users.users.${config.variables.user.name}.extraGroups = [ "audio" ];

  sound.enable = true;
  hardware.pulseaudio.support32Bit = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

  };

  # Low Latency audio
  environment.etc = {
    "pipewire/pipewire.d/99-lowlatency.conf".source = json.generate "99-lowlatency.conf" {
      context.properties.default.clock.min-quantum = config.variables.sound.quantum;
    };

    # pulse clients config
    "pipewire/pipewire-pulse.d/99-lowlatency.conf".source = json.generate "99-lowlatency.conf" {
      context.modules = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            nice.level = -15;
            rt.prio = 88;
            rt.time.soft = 200000;
            rt.time.hard = 200000;
          };
          flags = ["ifexists" "nofail"];
        }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = quantum-rate;
            pulse.min.quantum = quantum-rate;
            pulse.min.frag = quantum-rate;
            server.address = ["unix:native"];
          };
        }
      ];

      stream.properties = {
        node.latency = quantum-rate;
        resample.quality = 1;
      };
    };

    "wireplumber/main.lua.d/99-alsa-lowlatency.lua".text = ''
      alsa_monitor.rules = {
        {
          matches = {{{ "node.name", "matches", "alsa_output.*" }}};
          apply_properties = {
            ["audio.format"] = "S32LE",
            ["audio.rate"] = ${toString (config.variables.sound.rate * 2)},
            ["api.alsa.period-size"] = 2,
          },
        },
      }
    '';
  };
}
