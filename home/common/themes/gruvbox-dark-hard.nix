{ lib, ... }:
{
  wallpaper = lib.mkDefault ../../backgrounds/gruvbox_yf23.png;

  colorScheme = {
    slug = "gruvbox-dark-hard";
    name = "Gruvbox24 Dark Hard";
    palette = {
      base00 = "#1d2021"; # ----
      base01 = "#3c3836"; # ---
      base02 = "#504945"; # --
      base03 = "#665c54"; # -
      base04 = "#bdae93"; # +
      base05 = "#d5c4a1"; # ++
      base06 = "#ebdbb2"; # +++
      base07 = "#fbf1c7"; # ++++
      base08 = "#fb4934"; # Red
      base09 = "#fabd2f"; # Yellow
      base0A = "#fe8019"; # N/A (Yellow Alt in this case)
      base0B = "#b8bb26"; # Green
      base0C = "#8ec07c"; # Cyan/Aqua
      base0D = "#83a598"; # Blue
      base0E = "#d3869b"; # Purple
      base0F = "#d65d0e"; # N/A (Brown/Orange in this case)
      base10 = "#171c1c"; # ---- darkened by 2%
      base11 = "#151919"; # ---- darkened by 3%
      # All these need to be fixed to be light according to the spec
      base12 = "#fb5d4b"; # Red lightened by 5%
      base13 = "#FAC747"; # Yellow lightened by 5%
      base14 = "#cdcf2a"; # Green lightened by 5%
      base15 = "#9dc88d"; # Cyan/Aqua lightened by 5%
      base16 = "#92B0A4"; # Blue lightened by 5%
      base17 = "#db9aab"; # Purple lightened by 5%
    };
  };
}
