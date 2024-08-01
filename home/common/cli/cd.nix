{ pkgs, ... }:
{
  home.packages = with pkgs; [
    abcde
    flac
    lsscsi
  ];

  home.file.".abcde.conf".text = ''
        # Actions to take: do the replaygain step (disabled by default)
        ACTIONS=cddb,read,encode,replaygain,tag,move,clean

        # Default to FLAC encoding
        OUTPUTTYPE=flac

        # Customize the filename format
        OUTPUTFORMAT='\''${ARTISTFILE}/''${ALBUMFILE}/''${TRACKNUM} - ''${TRACKFILE}'
        VAOUTPUTFORMAT='Compilations/''${ALBUMFILE}/''${TRACKNUM} - ''${ARTISTFILE} - ''${TRACKFILE}'


        # Don't translate spaces to underscores in filenames
        mungefilename ()
        {
    	          echo "$@" | sed s,:,\ -,g | tr / _ | tr -d \'\"\?\[:cntrl:\]
        }

        # Prepend a leading 0 to track # even with < 10 tracks
        PADTRACKS=y

        # Preserve relative volume differences between the tracks of an album
        BATCHNORM=y

        # Run on at most 6 cores
        MAXPROCS=6

        # Set read offset according to http://www.accuraterip.com/driveoffsets.htm
        # Use `lsscsi` to identify the drive
        CDPARANOIAOPTS="-O 6"

        # Put the temporary .wav files on /tmp (SSD-backed)
        WAVOUTPUTDIR="''${TMPDIR:-/tmp}"

        # Open the tray after ripping
        EJECTCD=y
        # Close the tray before ripping
        pre_read ()
        {
                eject -t
        }
  '';
}
