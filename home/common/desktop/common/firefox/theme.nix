{
  profile,
  config,
  pkgs,
  ...
}:
let
  colors = config.colors;
  # Cascade
  cascade = pkgs.fetchFromGitHub {
    owner = "andreasgrafen";
    repo = "cascade";
    rev = "2f70e8619ce5c721fe9c0736b25c5a79938f1215";
    sha256 = "sha256-HOOBQ1cNjsDTFSymB3KjiZ1jw3GL16LF/RQxdn0sxr0=";
  };
  cascadeSrc = cascade + "/chrome/includes/cascade-";

  # Config
  chromePath = ".mozilla/firefox/${profile}/chrome";
  cascadePath = "${chromePath}/includes/cascade-";
  cascade-colors =
    ''
      :root {
        /* These colours are (mainly) used by the
        Container Tabs Plugin */
        --uc-identity-colour-blue:      #${colors.blue}          !important;
        --uc-identity-colour-turquoise: #${colors.cyan}          !important;
        --uc-identity-colour-green:     #${colors.green}         !important;
        --uc-identity-colour-yellow:    #${colors.yellow}        !important;
        --uc-identity-colour-orange:    #${colors.yellow-bright} !important;
        --uc-identity-colour-red:       #${colors.red}           !important;
        --uc-identity-colour-pink:      #${colors.purple}        !important;
        --uc-identity-colour-purple:    #${colors.purple-bright} !important;

        /*  Cascades main Colour Scheme */
        --uc-base-colour:               #${colors.background}     !important;
        --uc-highlight-colour:          #${colors.background-alt} !important;
        --uc-inverted-colour:           #${colors.foreground}     !important;
        --uc-muted-colour:              #${colors.foreground-alt} !important;
        --uc-accent-colour:             #${colors.accent}         !important;
      }
    ''
    + builtins.readFile ./cascade-colors.css;
  cascade-custom = ''
    :root {
      /* Letterboxing fix */
      --tabpanel-background-color: var(--uc-base-colour) !important;
    }
  '';
  cascade-chrome =
    builtins.readFile (cascade + "/chrome/userChrome.css")
    + ''
      @import 'includes/custom.css';
    '';
  about-pages = ''
    @-moz-document url-prefix("about:") {
      :root {
        --t-bg:      #${colors.background}     !important;
        --t-lbg:     #${colors.background-alt} !important;
        --t-fg:      #${colors.foreground}     !important;
        --t-muted:   #${colors.foreground-alt} !important;
        --t-accent:  #${colors.accent}         !important;
        --t-daccent: color-mix(in srgb, var(--t-accent) 41%, transparent) !important;
        --t-danger:  #${colors.red-bright}     !important;
        --t-warning: #${colors.purple}         !important;
        --t-error:   #${colors.red}            !important;
        --t-darken:  rgba(249,249,250,0.05)  !important; 

        --in-content-page-color:          var(--t-fg) !important;
        --in-content-deemphasized-text:   var(--t-muted) !important;
        --in-content-page-background:     var(--t-bg) !important;
        --in-content-box-background:      var(--t-lbg) !important;
        --in-content-box-background-odd:  var(--t-darken) !important; 
        --in-content-box-info-background: var(--t-darken) !important;

        --in-content-border-color: var(--t-muted) !important;
        --in-content-border-hover: var(--t-darken) !important;
        --in-content-border-invalid: var(--t-error) !important;

        --in-content-error-text-color: var(--t-error) !important;

        --in-content-button-background: var(--t-lbg) !important;
        --in-content-button-background-hover: var(--t-darken) !important;
        --in-content-button-background-active: var(--t-darken) !important;
        --in-content-icon-color: var(--t-fg) !important;

        --in-content-primary-button-text-color: var(--t-bg) !important;
        --in-content-primary-button-background: var(--t-accent) !important;
        --in-content-primary-button-background-hover: var(--t-daccent) !important;
        --in-content-primary-button-background-active: var(--t-darken) !important;

        --in-content-danger-button-background: var(--t-danger) !important;
        --in-content-danger-button-background-hover: color-mix(in srgb, currentColor 41%, transparent) !important;
        --in-content-danger-button-background-active: var(--t-danger) !important;

        --in-content-table-background: var(--t-bg) !important;

        --card-outline-color: var(--t-muted) !important;

        --dialog-warning-text-color: var(--t-warning) !important;

        /* Light Mode fix */
        --in-content-accent-color: var(--t-accent) !important;
        --in-content-accent-color-active: var(--t-daccent) !important;
        --in-content-link-color: var(--t-accent) !important;
        --in-content-link-color-active: var(--t-daccent) !important;
        --in-content-link-color-hover: var(--t-daccent) !important;

        /* About Blank */
        background-color: var(--t-bg);
      }
      * { font-size: 15px !important; }
    }
  '';
in
{
  # Config
  "${chromePath}/includes/custom.css".text = cascade-custom;
  "${chromePath}/userChrome.css".text = cascade-chrome;
  "${chromePath}/userContent.css".text = about-pages;
  "${cascadePath}colours.css".text = cascade-colors;
  # Cascade
  "${cascadePath}config.css".source = "${cascadeSrc}config.css";
  "${cascadePath}floating-panel.css".source = "${cascadeSrc}floating-panel.css";
  "${cascadePath}layout.css".source = "${cascadeSrc}layout.css";
  "${cascadePath}nav-bar.css".source = "${cascadeSrc}nav-bar.css";
  "${cascadePath}responsive-windows-fix.css".source = "${cascadeSrc}responsive-windows-fix.css";
  "${cascadePath}responsive.css".source = "${cascadeSrc}responsive.css";
  "${cascadePath}tabs.css".source = "${cascadeSrc}tabs.css";
}
