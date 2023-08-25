{ lib, config, ... }:
let
  cacheHome = lib.strings.removePrefix "/home/babeuh/" config.xdg.cacheHome; # Default: .cache
  configHome = lib.strings.removePrefix "/home/babeuh/" config.xdg.configHome; # Default: .config
  dataHome = lib.strings.removePrefix "/home/babeuh/" config.xdg.dataHome; # Default: .local/share
  stateHome = lib.strings.removePrefix "/home/babeuh/" config.xdg.stateHome; # Default: .local/state
in {
  home.persistence."/persist/home/babeuh" = {
    removePrefixDirectory = true;
    allowOther = true;
    directories = [
      "Data/Archive"
      "Data/KeePassXC"
      "Data/Music"
      "Data/Obsidian Vault"
      "Data/Projects"
      "Data/Pictures"
      "Data/Videos"
      "Firefox/.mozilla/firefox/"
      "Flatpak/${dataHome}/flatpak"
      "Multiviewer-for-f1/${configHome}/Multiviewer for F1"
      "Spotify/${configHome}/spotify"
      "Spotify/${cacheHome}/spotify"
      "Steam/${dataHome}/Steam"
      "Steam/${dataHome}/vulkan"
      "Syncthing/${configHome}/syncthing"
      "WebCord/${configHome}/WebCord"
      "Wireplumber/${stateHome}/wireplumber/default-profile"
      "Wireplumber/${configHome}/wireplumber"
      "Fish/${dataHome}/fish"
      "SSH/.ssh"
    ];
    files = [
      "Bash/.bash_history"
    ];
  };
}
