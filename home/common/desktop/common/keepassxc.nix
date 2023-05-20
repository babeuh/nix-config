{ pkgs, ... }: {
  home.packages = with pkgs; [ keepassxc ];
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC";
    };

    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      ExecStart = "%h/.nix-profile/bin/keepassxc";
      Restart = "no";
    };
  };
}

