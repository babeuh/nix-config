{ pkgs, ... }: {
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [ 
      cozette
    ];

    fontconfig.defaultFonts = {
      monospace = [ "CozetteVector" ];
    };
  };
}
