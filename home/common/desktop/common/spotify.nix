{ pkgs, ... }:
let
 spotifywm-desktop = pkgs.makeDesktopItem {
    name = "spotifywm-desktop";
    desktopName = "Spotify";
    exec = "${pkgs.spotifywm}/bin/spotifywm";
  };
in {
  home.packages = [ spotifywm-desktop pkgs.spotifywm ];
}
