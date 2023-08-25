{ pkgs, config, lib, ... }:
let
  cacheHome = lib.strings.removePrefix "~/" config.xdg.cacheHome;
in {
  home.packages = with pkgs; [ keepassxc ];
  xdg.configFile."keepassxc/keepassxc.ini".source = (pkgs.formats.ini { }).generate "keepassxc.ini" {
    General = {
      ConfigVersion = 2;
    };

    Browser = {
      Enabled = true;
    };

    GUI = {
      MinimizeOnClose = true;
      MinimizeToTray = true;
      ShowTrayIcon = true;
      TrayIconAppearance = "monochrome-light";
    };

    PasswordGenerator = {
      AdditionalChars = "";
      ExcludedChars = "";
      Length = 32;
    };
  };
  home.file."${cacheHome}/keepassxc/keepassxc.ini".source = (pkgs.formats.ini { }).generate "keepassxc.ini" {
    General = {
      LastActiveDatabase = "${config.home.homeDirectory}/KeePassXC/Personal.kdbx";
      LastDatabase = "${config.home.homeDirectory}/KeePassXC/Personal.kdbx";
      LastOpenedDatabase = "${config.home.homeDirectory}/KeePassXC/Personal.kdbx";
    };
  };
}

