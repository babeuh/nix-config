{ lib, config, ... }:
let
  cacheHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.cacheHome; # Default: .cache
  configHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome; # Default: .config
  dataHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome; # Default: .local/share
  stateHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome; # Default: .local/state
in {
  home.persistence."/persist/${config.home.homeDirectory}" = {
    removePrefixDirectory = true;
    allowOther = true;
    directories = [
      "Data/Archive"
      "Data/KeePassXC"
      "Data/Mail"
      "Data/Music"
      "Data/Obsidian Vault"
      "Data/Pictures"
      "Data/Videos"
      "Firefox/.mozilla/firefox/"
      "Flatpak/${dataHome}/flatpak"
      "KeepassXC/${configHome}/keepassxc"
      "Multiviewer-for-f1/${configHome}/Multiviewer for F1"
      "Obsidian/${configHome}/obsidian"
      "Protonmail/${configHome}/protonmail"
      "Protonmail/${cacheHome}/protonmail"
      "Protonmail/${dataHome}/protonmail"
      "Spotify/${configHome}/spotify"
      "Spotify/${cacheHome}/spotify"
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
