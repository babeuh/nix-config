{ pkgs, ... }: {
  home.packages = with pkgs; [
    heroic
    prismlauncher
    rpcs3

    lutris

    gamemode

    protonup-ng
  ];
}
