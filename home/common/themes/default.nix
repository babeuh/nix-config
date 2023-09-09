{ config, lib, ... }:
with lib;
let
  base-colors = config.colorScheme.colors;
    hexColorType = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = x: isString x && !(hasPrefix "#" x);
  };
in
{
  options.colors = mkOption {
      type = with types; attrsOf (
        coercedTo str (removePrefix "#") hexColorType
      );
      default = {
        background               = base-colors.base00;
        background-alt           = base-colors.base01; # Used for status bars
        background-selection     = base-colors.base02; # TODO: not sure about this
        background-least         = base-colors.base03; # Least light/dark background
        background-more          = base-colors.base10; # More dark/light background
        background-most          = base-colors.base11; # Most dark/light background
        foreground               = base-colors.base05;
        foreground-alt           = base-colors.base04; # Used for status bars
        foreground-more          = base-colors.base06; # More light/dark foreground
        foreground-most          = base-colors.base07; # Most light/dark foreground
        accent                   = base-colors.base09;

        # Colors
        black         = base-colors.base01;
        black-bright  = base-colors.base02;
        white         = base-colors.base06;
        white-bright  = base-colors.base07;
        red           = base-colors.base08;
        red-bright    = base-colors.base12;
        yellow        = base-colors.base09;
        yellow-bright = base-colors.base13;
        orange-brown  = base-colors.base0A;
        green         = base-colors.base0B;
        green-bright  = base-colors.base14;
        cyan          = base-colors.base0C;
        cyan-bright   = base-colors.base15;
        blue          = base-colors.base0D;
        blue-bright   = base-colors.base16;
        purple        = base-colors.base0E;
        purple-bright = base-colors.base17;
      };
    };
}
