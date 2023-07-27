{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      cozette
    ];
    fontconfig.defaultFonts = {
      monospace = [ "CozetteVector" ];
    };
  };
}
