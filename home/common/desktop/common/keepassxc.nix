{ pkgs, config, lib, ... }:
let
  cacheHome = lib.strings.removePrefix "~/" config.xdg.cacheHome;
in {
  home.packages = with pkgs; [ keepassxc ];
  home.file."${cacheHome}/keepassxc/keepassxc.ini".source = (pkgs.formats.ini { }).generate "keepassxc.ini" {
    General = {
      LastActiveDatabase = "${config.home.homeDirectory}/KeePassXC/Personal.kdbx";
      LastDatabase = "${config.home.homeDirectory}/KeePassXC/Personal.kdbx";
      LastOpenedDatabase = "${config.home.homeDirectory}/KeePassXC/Personal.kdbx";
    };
  };
}

