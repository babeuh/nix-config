{ pkgs, username, ... }: {
  programs.kdeconnect = {
    enable = true;
    package = pkgs.valent;
  };
  environment.persistence."/persist".users.${username}.directories = [
    "Valent/.config/valent"
  ];
}
