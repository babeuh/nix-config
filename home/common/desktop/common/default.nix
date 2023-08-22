{ pkgs, hostname, lib, outputs, ... }: {
  imports = [
    ./discord.nix
    ./firefox
    ./gtk.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./qt.nix
    ./alacritty.nix
    ./spotify.nix
    ./keepassxc.nix
    ./dunst.nix
    ./helix.nix
    ./obsidian.nix
  ];

  home.packages = with pkgs; [
    pulseaudio
    gimp
    krita
    yubioath-flutter
    yubikey-touch-detector
    multiviewer-for-f1
    kicad
    qbittorrent
  ];
  xdg.mimeApps.enable = true;
}
