{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = self: _super: import ../pkgs { pkgs = self; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = self: super: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    betterlockscreen = super.betterlockscreen.overrideAttrs (oldAttrs: rec {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cp betterlockscreen $out/bin/betterlockscreen
        wrapProgram "$out/bin/betterlockscreen" \
          --prefix PATH : "$out/bin:${
            with super;
            inputs.nixpkgs.lib.makeBinPath [
              feh
              bc
              coreutils
              dbus
              dunst
              i3lock-color
              gawk
              gnugrep
              gnused
              imagemagick
              procps
              xorg.xdpyinfo
              xorg.xrandr
              xorg.xset
              xorg.xrdb
            ]
          }"

        runHook postInstall
      '';
    });
  };
}
