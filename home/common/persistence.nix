{ lib, config, ... }:
let
  cacheHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.cacheHome; # Default: .cache
  configHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome; # Default: .config
  dataHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome; # Default: .local/share
  stateHome = lib.strings.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome; # Default: .local/state
in
{
  home.persistence."/persist/${config.home.homeDirectory}" = {
    removePrefixDirectory = true;
    allowOther = true;
    directories = [
      "Android/${configHome}/Google"
      "Android/${configHome}/.android"
      "Beeper/${configHome}/Beeper"
      "Data/Archive"
      "Data/KeePassXC"
      "Data/Mail"
      "Data/Music"
      "Data/Obsidian Vault"
      "Data/Pictures"
      "Data/Videos"
      "Firefox/.mozilla/firefox/"
      "Fish/${dataHome}/fish"
      "Flatpak/${dataHome}/flatpak"
      "KeepassXC/${configHome}/keepassxc"
      "Multiviewer-for-f1/${configHome}/Multiviewer for F1"
      "Obsidian/${configHome}/obsidian"
      "Protonmail/${configHome}/protonmail"
      "Protonmail/${cacheHome}/protonmail"
      "Protonmail/${dataHome}/protonmail"
      "RPCS3/${configHome}/rpcs3"
      "Spotify/${configHome}/spotify"
      "Spotify/${cacheHome}/spotify"
      "SSH/.ssh"
      "Syncthing/${configHome}/syncthing"
      "WebCord/${configHome}/WebCord"
      "Wireplumber/${stateHome}/wireplumber/default-profile"
      "Wireplumber/${configHome}/wireplumber"
      "Zettlr/Zettlr"
      "Zettlr/${configHome}/Zettlr"
      "Zotero/.zotero"
      "Zotero/Zotero"
    ];
    files = [ "Bash/.bash_history" ];
  };
}
