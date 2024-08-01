{ lib, username, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
    ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Steam needs this to find Proton-GE and other 3rd party windows compat tools
  environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";

  environment.persistence."/persist".users.${username}.directories = [
    "Steam/.local/share/Steam"
    "Steam/.local/share/vulkan"
  ];

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;

    settings = {
      sunshine_name = "atlas";

      resolutions = "[1280x720, 1920x1080, 2560x1440,]";

      upnp = "off";
    };
  };
}
