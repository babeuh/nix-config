{ pkgs, lib, config, username, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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
}
