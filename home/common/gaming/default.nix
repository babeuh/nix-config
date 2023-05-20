{ pkgs, ... }: {
  home.packages = with pkgs; [
    heroic
    prismlauncher
    lutris

    gamemode

    protonup-ng
  ];
}
