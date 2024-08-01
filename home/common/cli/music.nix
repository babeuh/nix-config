{ pkgs, config, ... }:
let
  songinfo = pkgs.writeShellScriptBin "songinfo" ''
    music_dir="$HOME/Music"
    previewdir="$XDG_CONFIG_HOME/ncmpcpp/previews"
    filename="$(${pkgs.mpc-cli}/bin/mpc --format "$music_dir"/%file% current)"
    previewname="$previewdir/$(${pkgs.mpc-cli}/bin/mpc --format %album% current | base64).png"

    [ -e "$previewname" ] || ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$filename" -an -vf scale=128:128 "$previewname" > /dev/null 2>&1

    ${pkgs.libnotify}/bin/notify-send -r 27072 "Now Playing" "$(${pkgs.mpc-cli}/bin/mpc --format '%title% \n%artist% - %album%' current)" -i "$previewname"
  '';
in
{
  home.packages = with pkgs; [ mpc-cli ];
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "MPD"
      }
      audio_output {
        type                    "fifo"
        name                    "mpd_vis"
        path                    "/tmp/mpd.fifo"
        format                  "44100:16:2"
      }
    '';
  };

  services.mpd-mpris.enable = true;

  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };

    mpdMusicDir = "~/Music";
    settings = {
      execute_on_song_change = "${songinfo}/bin/songinfo";
      # Visualizer
      locked_screen_width_part = 50;
      startup_screen = "visualizer";
      startup_slave_screen = "playlist";
      startup_slave_screen_focus = "yes";
      visualizer_data_source = "/tmp/mpd.fifo";
      visualizer_output_name = "mpd_vis";
      visualizer_in_stereo = "yes";
      visualizer_type = "spectrum";
      visualizer_look = "●●";
    };
  };
}
