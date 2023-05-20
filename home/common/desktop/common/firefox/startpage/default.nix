{ profile, config, ... }: 
let
  inherit (config.colorscheme) colors;
  # Config
  startpagePath = ".mozilla/firefox/${profile}/chrome/startpage";
  startpage-theme = ''
    :root {
      --bg:        #${colors.base00};
      --fg:        #${colors.base05};
      --second-bg: #${colors.base01};
      --accent:    #${colors.base0A};
    }
  '';
  startpage-imports = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <title>~/startpage</title>
      <style>${startpage-theme}</style>
      <style>${builtins.readFile ./style.css}</style>
      <script>${builtins.readFile ./main.js}</script>
    </head>
  '';
in {
  "${startpagePath}/index.html".text = startpage-imports + builtins.readFile ./index.html;
}
