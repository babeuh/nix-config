{ profile, config, pkgs, ... }:
let
  inherit (config.colorscheme) colors;
  # Cascade
  cascade = pkgs.fetchFromGitHub {
    owner = "andreasgrafen";
    repo = "cascade";
    rev = "78ba95b83ef74b0080464540929bc5e724279ee4";
    sha256 = "O3BqtbgqdrhOxunrZN7LaSrVUEcbdtqri7wltMcnqo4=";
  };
  cascadeSrc = cascade + "/chrome/includes/cascade-";

  # Config
  chromePath  = ".mozilla/firefox/${profile}/chrome";
  cascadePath = "${chromePath}/includes/cascade-";
  cascade-colors = ''
    :root {
      /* These colours are (mainly) used by the
      Container Tabs Plugin */
      --uc-identity-colour-blue:      #${colors.base0D} !important;
      --uc-identity-colour-turquoise: #${colors.base0C} !important;
      --uc-identity-colour-green:     #${colors.base0B} !important;
      --uc-identity-colour-yellow:    #${colors.base0A} !important;
      --uc-identity-colour-orange:    #${colors.base09} !important;
      --uc-identity-colour-red:       #${colors.base08} !important;
      --uc-identity-colour-pink:      #${colors.base0F} !important;
      --uc-identity-colour-purple:    #${colors.base0E} !important;

      /*  Cascades main Colour Scheme */
      --uc-base-colour:               #${colors.base00} !important;
      --uc-highlight-colour:          #${colors.base01} !important;
      --uc-inverted-colour:           #${colors.base05} !important;
      --uc-muted-colour:              #${colors.base05} !important;
      --uc-accent-colour:             var(--uc-identity-colour-yellow) !important;
    }
  '' + builtins.readFile ./cascade-colors.css;
  cascade-custom = ''
    :root {
      /* Letterboxing fix */
      --tabpanel-background-color: var(--uc-base-colour) !important;
    }
  '';
  cascade-chrome = builtins.readFile (cascade + "/chrome/userChrome.css") + ''
    @import 'includes/custom.css';
  '';
  about-pages = ''
    @-moz-document url-prefix("about:") {
      :root {
        --t-bg:      #${colors.base00} !important;
        --t-lbg:     #${colors.base01} !important;
        --t-fg:      #${colors.base05} !important;
        --t-muted:   #${colors.base04} !important;
        --t-accent:  #${colors.base0A} !important;
        --t-daccent: color-mix(in srgb, var(--t-accent) 41%, transparent) !important;
        --t-danger:  #${colors.base08} !important;
        --t-warning: #${colors.base0E} !important;
        --t-error:   #${colors.base0F} !important;
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
in {
  # Config
  "${chromePath}/includes/custom.css".text          = cascade-custom;
  "${chromePath}/userChrome.css".text               = cascade-chrome;
  "${chromePath}/userContent.css".text              = about-pages;
  "${cascadePath}colours.css".text                  = cascade-colors;
  # Cascade
  "${cascadePath}config-mouse.css".source           = "${cascadeSrc}config-mouse.css";
  "${cascadePath}config.css".source                 = "${cascadeSrc}config.css";
  "${cascadePath}floating-panel.css".source         = "${cascadeSrc}floating-panel.css";
  "${cascadePath}layout.css".source                 = "${cascadeSrc}layout.css";
  "${cascadePath}nav-bar.css".source                = "${cascadeSrc}nav-bar.css";
  "${cascadePath}responsive-windows-fix.css".source = "${cascadeSrc}responsive-windows-fix.css";
  "${cascadePath}responsive.css".source             = "${cascadeSrc}responsive.css";
  "${cascadePath}tabs.css".source                   = "${cascadeSrc}tabs.css";
}
