{ pkgs, ... }: {
  home.packages = [ pkgs.playerctl ];
  systemd.user.services.playerctld = {
    Unit = {
      Description = "MPRIS media player daemon";
      After = "multi-user.target graphical.target";
    };

    Install.WantedBy = [ "default.target" ];

    Service = {
      ExecStart = "${pkgs.playerctl}/bin/playerctld";
      Type = "dbus";
      BusName = "org.mpris.MediaPlayer2.playerctld";
    };
  };
}
