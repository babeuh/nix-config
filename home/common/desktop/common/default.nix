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

  xdg.configFile."Mullvad VPN/gui_settings.json".source = (pkgs.formats.json { }).generate "gui_settings.json" {
    preferredLocale = "system";
    autoConnect = false;
    enableSystemNotifications = true;
    monochromaticIcon = true;
    startMinimized = false;
    unpinnedWindow = true;
    browsedForSplitTunnelingApplications = [];
    changelogDisplayedForVersion = pkgs.mullvad-vpn.version;
  };

  xdg.configFile."MultiViewer for F1/config.json".source = (pkgs.formats.json { }).generate "config.json" {
    accountSetupCompleted = true;
    analyticsConsent = "denied";
    onboardingTutorialCompleted = true;
    onboardingPrecheckCompleted = true;
  };
}
