{
  config,
  username,
  pkgs,
  ...
}:
{
  imports = [
    ../../common/gaming
    ../../common/virtualisation
    ../../common/flatpak
    ../../common/openrgb
    ../../common/syncthing.nix

    ../../common/hardware/nvidia.nix
    ../../common/hardware/sweep.nix
    ../../common/hardware/numworks.nix
    ../../common/hardware/drawing.nix
    ../../common/hardware/android.nix
    ../../common/filesystem.nix
    ./hardware-configuration.nix
  ];
  # Syncthing
  services.syncthing.enable = true;
  services.syncthing.settings.devices = {
    "phone".id = "C2BBNTV-4Q4XUXE-M2RMD3N-PFIVCCB-MMFINAX-UP4S5MZ-BRODLAL-BVES5AG";
    "macbook".id = "KEHRQGU-Z4ZYUOD-QPMDWCA-U7SYMSX-KY5SKIB-PEZCY6C-ZOQ5AGR-XKINZQK";
  };
  services.syncthing.settings.folders = {
    "KeePassXC" = {
      id = "4wmxy-pdg0y";
      label = "KeePassXC";
      path = "${config.variables.user.home}/KeePassXC";
      devices = [
        "macbook"
        "phone"
      ];
    };
    "Obsidian Vault" = {
      id = "wlwgj-bhqfx";
      label = "Obsidian Vault";
      path = "${config.variables.user.home}/Obsidian Vault";
      devices = [
        "macbook"
        "phone"
      ];
    };
  };

  # Sound config
  variables.sound = {
    quantum = 256;
    rate = 92000;
    allowed-rates = [
      44100
      48000
      88200
      96000
    ];
    wireplumberExtraConfig = pkgs.writeTextDir "wireplumber/main.lua.d/51-host-config.lua" (
      builtins.readFile ./51-host-config.lua
    );
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO0Kt6R4rqT3r9eRqKUgrLhvTbLWP+vNl35HcN/lpwev09OAk6P0jmF6uslB8H80A1sWm3vNrQCuaQIMDjNG4Eo="
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGHBVQD7JXUzrhQV8vWf7+PNe+U2CVtiNPNe/7dbERaw3p6KDCjDS408RqIktUrVgUwYaXfXB40Nfg7C9nYhSEU="
  ];
}
