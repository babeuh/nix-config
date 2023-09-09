{ profile, config, ... }: 
let
  colors = config.colors;
  # Config
  startpagePath = ".mozilla/firefox/${profile}/chrome/startpage";
  startpage-theme = ''
    :root {
      --bg:        #${colors.background};
      --fg:        #${colors.foreground};
      --second-bg: #${colors.background-alt};
      --accent:    #${colors.accent};
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
